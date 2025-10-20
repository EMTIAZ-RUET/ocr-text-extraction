"""
Configuration settings for the OCR backend service.
Uses Google Cloud Vision API for OCR processing.
"""
import os

# OCR Engine - Google Cloud Vision API only
OCR_ENGINE = "google"

# Google Cloud Vision Configuration
GOOGLE_APPLICATION_CREDENTIALS = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

# File Upload Configuration
MAX_FILE_SIZE_MB = 10
ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif"}
ALLOWED_CONTENT_TYPES = {
    "image/jpeg", "image/jpg", "image/png", "image/gif"
}
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024

# API Configuration
API_TITLE = "OCR Image Text Extraction API"
API_VERSION = "1.0.0"
API_DESCRIPTION = """
Production-ready OCR API using Google Cloud Vision API.
Upload JPG/JPEG/PNG/GIF images to extract text with confidence scores.
Features: Rate limiting, Redis caching, and optimized for Google Cloud Run deployment.
"""

# Redis Configuration
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379")
CACHE_TTL_SECONDS = int(os.getenv("CACHE_TTL_SECONDS", "3600"))  # 1 hour default

# Rate Limiting Configuration
RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", "30"))
RATE_LIMIT_WINDOW = os.getenv("RATE_LIMIT_WINDOW", "1/minute")

# CORS Configuration
ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Local development
    "http://localhost:5173",  # Vite dev server
    "http://localhost:8080",  # Local backend
    "http://localhost",       # Docker compose frontend
    "https://ocr-frontend-prdv6owkpq-uc.a.run.app",  # Cloud Run frontend
    "https://ocr-frontend-817219297051.us-central1.run.app",  # Alternative frontend URL
    "*"  # Allow all origins for Cloud Run (can be restricted to specific domains)
]

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
