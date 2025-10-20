"""
Google Cloud Vision OCR Service
"""
import time
from typing import Dict, Any
from google.cloud import vision
from google.api_core.exceptions import GoogleAPIError
import logging

logger = logging.getLogger(__name__)


class GoogleVisionOCR:
    """Google Cloud Vision OCR implementation"""
    
    def __init__(self):
        """Initialize Google Cloud Vision client"""
        try:
            self.client = vision.ImageAnnotatorClient()
            logger.info("Google Cloud Vision client initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Google Cloud Vision client: {str(e)}")
            raise
    
    def extract_text(self, image_bytes: bytes) -> Dict[str, Any]:
        """
        Extract text from image using Google Cloud Vision API
        
        Args:
            image_bytes: Image file content as bytes
            
        Returns:
            Dictionary containing extracted text, confidence, and processing time
        """
        start_time = time.time()
        
        try:
            # Create Vision API image object
            image = vision.Image(content=image_bytes)
            
            # Perform text detection
            response = self.client.text_detection(image=image)
            
            # Check for errors
            if response.error.message:
                raise GoogleAPIError(response.error.message)
            
            # Extract text and confidence
            texts = response.text_annotations
            
            if not texts:
                extracted_text = ""
                confidence = 0.0
            else:
                # First annotation contains the full text
                extracted_text = texts[0].description
                
                # Calculate average confidence from all detected text blocks
                if len(texts) > 1:
                    confidences = [
                        annotation.confidence 
                        for annotation in texts[1:] 
                        if hasattr(annotation, 'confidence')
                    ]
                    confidence = sum(confidences) / len(confidences) if confidences else 0.95
                else:
                    confidence = 0.95  # Default confidence for Google Vision
            
            processing_time = int((time.time() - start_time) * 1000)
            
            logger.info(f"Google Vision OCR completed in {processing_time}ms")
            
            return {
                "success": True,
                "ocr_engine": "google",
                "text": extracted_text.strip(),
                "confidence": round(confidence, 2),
                "processing_time_ms": processing_time
            }
            
        except GoogleAPIError as e:
            logger.error(f"Google Cloud Vision API error: {str(e)}")
            raise Exception(f"Google Cloud Vision API error: {str(e)}")
        except Exception as e:
            logger.error(f"Error during Google Vision OCR: {str(e)}")
            raise Exception(f"OCR processing failed: {str(e)}")
