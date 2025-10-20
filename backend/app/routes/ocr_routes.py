"""
OCR API Routes with Rate Limiting and Caching
"""
from fastapi import APIRouter, UploadFile, File, HTTPException, Request
from fastapi.responses import JSONResponse
from slowapi import Limiter
from slowapi.util import get_remote_address
import logging
from typing import Dict, Any

from config import (
    OCR_ENGINE, 
    MAX_FILE_SIZE_BYTES, 
    ALLOWED_EXTENSIONS, 
    ALLOWED_CONTENT_TYPES,
    RATE_LIMIT_WINDOW
)
from app.services.ocr_google import GoogleVisionOCR
from app.services.cache_service import cache_service

logger = logging.getLogger(__name__)

router = APIRouter()
limiter = Limiter(key_func=get_remote_address)

# Initialize Google Vision OCR
_google_ocr = None


def get_ocr_engine():
    """Get the Google Vision OCR engine instance"""
    global _google_ocr
    
    if _google_ocr is None:
        _google_ocr = GoogleVisionOCR()
    return _google_ocr


def validate_file(file: UploadFile) -> None:
    """
    Validate uploaded file
    
    Args:
        file: Uploaded file object
        
    Raises:
        HTTPException: If validation fails
    """
    # Check file extension
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided")
    
    file_ext = file.filename.lower().split('.')[-1]
    if file_ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid file type. Only {', '.join(ALLOWED_EXTENSIONS).upper()} files are allowed"
        )
    
    # Check content type
    if file.content_type not in ALLOWED_CONTENT_TYPES:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid content type. Allowed types: {', '.join(ALLOWED_CONTENT_TYPES)}"
        )


@router.post("/extract-text")
@limiter.limit(RATE_LIMIT_WINDOW)
async def extract_text(request: Request, file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Extract text from uploaded image using OCR with caching and rate limiting
    
    Args:
        request: FastAPI request object (for rate limiting)
        file: Uploaded JPG/JPEG/PNG/GIF image file
        
    Returns:
        JSON response with extracted text, confidence, and processing time
    """
    try:
        # Validate file
        validate_file(file)
        
        # Read file content
        image_bytes = await file.read()
        
        # Check file size
        if len(image_bytes) > MAX_FILE_SIZE_BYTES:
            raise HTTPException(
                status_code=400,
                detail=f"File size exceeds maximum allowed size of {MAX_FILE_SIZE_BYTES // (1024 * 1024)}MB"
            )
        
        if len(image_bytes) == 0:
            raise HTTPException(status_code=400, detail="Empty file uploaded")
        
        logger.info(f"Processing image with {OCR_ENGINE} OCR engine (size: {len(image_bytes)} bytes)")
        
        # Check cache first
        cached_result = cache_service.get_cached_result(image_bytes)
        if cached_result:
            logger.info("Returning cached OCR result")
            return cached_result
        
        # Get OCR engine and process
        ocr_engine = get_ocr_engine()
        result = ocr_engine.extract_text(image_bytes)
        
        # Cache the result
        cache_service.cache_result(image_bytes, result)
        
        logger.info(f"OCR processing successful: {len(result.get('text', ''))} characters extracted")
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error processing OCR request: {str(e)}")
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": str(e),
                "ocr_engine": OCR_ENGINE
            }
        )


@router.get("/health")
async def health_check() -> Dict[str, Any]:
    """Health check endpoint"""
    return {
        "status": "healthy",
        "ocr_engine": OCR_ENGINE,
        "cache_enabled": cache_service.enabled,
        "supported_formats": list(ALLOWED_EXTENSIONS)
    }


@router.get("/cache/stats")
async def get_cache_stats() -> Dict[str, Any]:
    """Get cache statistics"""
    return cache_service.get_cache_stats()


@router.delete("/cache/clear")
@limiter.limit("5/minute")
async def clear_cache(request: Request) -> Dict[str, Any]:
    """Clear all cached OCR results"""
    success = cache_service.clear_cache()
    return {
        "success": success,
        "message": "Cache cleared successfully" if success else "Failed to clear cache"
    }
