import axios from 'axios';

// For production deployment, use the Cloud Run backend URL
const API_BASE_URL = window.location.hostname.includes('run.app') 
  ? 'https://ocr-backend-prdv6owkpq-uc.a.run.app/api'
  : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api');

// Debug logging
console.log('Frontend hostname:', window.location.hostname);
console.log('API_BASE_URL:', API_BASE_URL);
console.log('VITE_API_BASE_URL:', import.meta.env.VITE_API_BASE_URL);

const ocrService = {
  /**
   * Extract text from an image file
   * @param {File} file - The image file to process
   * @returns {Promise} - API response with extracted text
   */
  extractText: async (file) => {
    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await axios.post(`${API_BASE_URL}/extract-text`, formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        timeout: 30000, // 30 second timeout
      });

      return response.data;
    } catch (error) {
      if (error.response) {
        // Server responded with error
        throw new Error(error.response.data.detail || error.response.data.error || 'OCR processing failed');
      } else if (error.request) {
        // Request made but no response
        throw new Error('No response from server. Please check if the backend is running.');
      } else {
        // Something else happened
        throw new Error(error.message || 'An unexpected error occurred');
      }
    }
  },

  /**
   * Check backend health
   * @returns {Promise} - Health check response
   */
  healthCheck: async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/health`, {
        timeout: 5000,
      });
      return response.data;
    } catch (error) {
      throw new Error('Backend is not reachable');
    }
  },
};

export default ocrService;
