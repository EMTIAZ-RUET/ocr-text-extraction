"""
Redis Cache Service for OCR Results
Provides caching functionality for identical images to improve performance
"""
import hashlib
import json
import logging
from typing import Dict, Any, Optional
import redis
from config import REDIS_URL, CACHE_TTL_SECONDS

logger = logging.getLogger(__name__)


class CacheService:
    """Redis-based caching service for OCR results"""
    
    def __init__(self):
        """Initialize Redis connection"""
        try:
            # Parse Redis URL for Cloud Run compatibility
            if REDIS_URL.startswith("redis://"):
                self.redis_client = redis.from_url(REDIS_URL, decode_responses=True)
            else:
                # Fallback for local development
                self.redis_client = redis.Redis(host='localhost', port=6379, decode_responses=True)
            
            # Test connection
            self.redis_client.ping()
            self.enabled = True
            logger.info("Redis cache service initialized successfully")
            
        except Exception as e:
            logger.warning(f"Redis not available, caching disabled: {str(e)}")
            self.redis_client = None
            self.enabled = False
    
    def _generate_cache_key(self, image_bytes: bytes) -> str:
        """
        Generate a unique cache key for image content
        
        Args:
            image_bytes: Image file content as bytes
            
        Returns:
            MD5 hash of the image content as cache key
        """
        image_hash = hashlib.md5(image_bytes).hexdigest()
        return f"ocr_result:{image_hash}"
    
    def get_cached_result(self, image_bytes: bytes) -> Optional[Dict[str, Any]]:
        """
        Retrieve cached OCR result for an image
        
        Args:
            image_bytes: Image file content as bytes
            
        Returns:
            Cached OCR result or None if not found
        """
        if not self.enabled:
            return None
            
        try:
            cache_key = self._generate_cache_key(image_bytes)
            cached_data = self.redis_client.get(cache_key)
            
            if cached_data:
                result = json.loads(cached_data)
                logger.info(f"Cache hit for key: {cache_key}")
                return result
            else:
                logger.debug(f"Cache miss for key: {cache_key}")
                return None
                
        except Exception as e:
            logger.error(f"Error retrieving from cache: {str(e)}")
            return None
    
    def cache_result(self, image_bytes: bytes, ocr_result: Dict[str, Any]) -> bool:
        """
        Cache OCR result for an image
        
        Args:
            image_bytes: Image file content as bytes
            ocr_result: OCR processing result to cache
            
        Returns:
            True if successfully cached, False otherwise
        """
        if not self.enabled:
            return False
            
        try:
            cache_key = self._generate_cache_key(image_bytes)
            
            # Add cache metadata
            cache_data = ocr_result.copy()
            cache_data["cached"] = True
            cache_data["cache_key"] = cache_key
            
            # Store in Redis with TTL
            self.redis_client.setex(
                cache_key,
                CACHE_TTL_SECONDS,
                json.dumps(cache_data)
            )
            
            logger.info(f"Cached result for key: {cache_key}")
            return True
            
        except Exception as e:
            logger.error(f"Error caching result: {str(e)}")
            return False
    
    def clear_cache(self) -> bool:
        """
        Clear all cached OCR results
        
        Returns:
            True if successfully cleared, False otherwise
        """
        if not self.enabled:
            return False
            
        try:
            # Find all OCR cache keys
            keys = self.redis_client.keys("ocr_result:*")
            if keys:
                self.redis_client.delete(*keys)
                logger.info(f"Cleared {len(keys)} cached results")
            return True
            
        except Exception as e:
            logger.error(f"Error clearing cache: {str(e)}")
            return False
    
    def get_cache_stats(self) -> Dict[str, Any]:
        """
        Get cache statistics
        
        Returns:
            Dictionary with cache statistics
        """
        if not self.enabled:
            return {"enabled": False, "message": "Redis cache not available"}
            
        try:
            info = self.redis_client.info()
            keys = self.redis_client.keys("ocr_result:*")
            
            return {
                "enabled": True,
                "total_keys": len(keys),
                "memory_usage": info.get("used_memory_human", "N/A"),
                "connected_clients": info.get("connected_clients", 0),
                "cache_ttl_seconds": CACHE_TTL_SECONDS
            }
            
        except Exception as e:
            logger.error(f"Error getting cache stats: {str(e)}")
            return {"enabled": False, "error": str(e)}


# Global cache service instance
cache_service = CacheService()
