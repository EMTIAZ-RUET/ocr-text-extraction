"""
OCR API Routes
"""
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import JSONResponse
import logging
from typing import Dict, Any

from config import (
    OCR_ENGINE, 
    MAX_FILE_SIZE_BYTES, 
    ALLOWED_EXTENSIONS, 
    ALLOWED_CONTENT_TYPES
)
from app.services.ocr_google import GoogleVisionOCR

logger = logging.getLogger(__name__)

router = APIRouter()

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
            detail="Invalid content type. Only JPEG images are allowed"
        )


@router.post("/extract-text")
async def extract_text(file: UploadFile = File(...)) -> Dict[str, Any]:
    """
    Extract text from uploaded image using OCR
    
    Args:
        file: Uploaded JPG/JPEG image file
        
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
        
        # Get OCR engine and process
        ocr_engine = get_ocr_engine()
        result = ocr_engine.extract_text(image_bytes)
        
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
        "ocr_engine": OCR_ENGINE
    }
