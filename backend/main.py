"""
FastAPI OCR Backend Service
Main application entry point with rate limiting and caching
"""
import logging
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from config import (
    API_TITLE,
    API_VERSION,
    API_DESCRIPTION,
    ALLOWED_ORIGINS,
    LOG_LEVEL,
    OCR_ENGINE,
    RATE_LIMIT_WINDOW
)
from app.routes import ocr_routes

# Configure logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address)

# Create FastAPI application
app = FastAPI(
    title=API_TITLE,
    version=API_VERSION,
    description=API_DESCRIPTION
)

# Add rate limiter to app state
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(ocr_routes.router, prefix="/api", tags=["OCR"])

# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "message": "OCR Image Text Extraction API",
        "version": API_VERSION,
        "ocr_engine": OCR_ENGINE,
        "endpoints": {
            "extract_text": "/api/extract-text",
            "health": "/api/health",
            "docs": "/docs"
        }
    }

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    """Handle uncaught exceptions"""
    logger.error(f"Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": "Internal server error",
            "detail": str(exc)
        }
    )

if __name__ == "__main__":
    import uvicorn
    logger.info(f"Starting OCR API with {OCR_ENGINE} engine")
    uvicorn.run(app, host="0.0.0.0", port=8080)
