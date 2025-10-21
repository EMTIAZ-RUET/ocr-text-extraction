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
ALLOWED_EXTENSIONS = {"jpg", "jpeg"}
ALLOWED_CONTENT_TYPES = {"image/jpeg", "image/jpg"}
MAX_FILE_SIZE_BYTES = MAX_FILE_SIZE_MB * 1024 * 1024

# API Configuration
API_TITLE = "OCR Image Text Extraction API"
API_VERSION = "1.0.0"
API_DESCRIPTION = """
OCR API using Google Cloud Vision API.
Upload JPG/JPEG images to extract text with confidence scores.
Optimized for Google Cloud Run deployment.
"""

# CORS Configuration
ALLOWED_ORIGINS = [
    "http://localhost:3000",  # Local development
    "http://localhost:5173",  # Vite dev server
    "http://localhost:8080",  # Local backend
    "http://localhost",       # Docker compose frontend
    "*"  # Allow all origins for Cloud Run
]

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
