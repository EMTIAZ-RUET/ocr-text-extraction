import React, { useState, useEffect } from 'react';
import {
  Box,
  Typography,
  Paper,
  Chip,
  Alert,
  Snackbar,
} from '@mui/material';
import ImageSearchIcon from '@mui/icons-material/ImageSearch';
import ImageUpload from '../components/ImageUpload';
import ResultDisplay from '../components/ResultDisplay';
import ocrService from '../services/ocrService';

const OCRPage = () => {
  const [loading, setLoading] = useState(false);
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');
  const [backendStatus, setBackendStatus] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'info' });

  useEffect(() => {
    // Check backend health on mount
    checkBackendHealth();
  }, []);

  const checkBackendHealth = async () => {
    try {
      const health = await ocrService.healthCheck();
      setBackendStatus(health);
    } catch (err) {
      setBackendStatus({ status: 'offline' });
    }
  };

  const handleUpload = async (file) => {
    setLoading(true);
    setError('');
    setResult(null);

    try {
      const response = await ocrService.extractText(file);
      setResult(response);
      setSnackbar({
        open: true,
        message: 'Text extracted successfully!',
        severity: 'success',
      });
    } catch (err) {
      const errorMessage = err.message || 'Failed to extract text';
      setError(errorMessage);
      setSnackbar({
        open: true,
        message: errorMessage,
        severity: 'error',
      });
    } finally {
      setLoading(false);
    }
  };

  const handleCloseSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  return (
    <Box sx={{ py: 4 }}>
      {/* Header */}
      <Paper
        elevation={4}
        sx={{
          p: 4,
          mb: 4,
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
          color: 'white',
          textAlign: 'center',
        }}
      >
        <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'center', mb: 2 }}>
          <ImageSearchIcon sx={{ fontSize: 48, mr: 2 }} />
          <Typography variant="h3" component="h1" fontWeight="bold">
            OCR Text Extraction
          </Typography>
        </Box>
        <Typography variant="h6" sx={{ opacity: 0.9 }}>
          Extract text from images using advanced OCR technology
        </Typography>
        
        {/* Backend Status */}
        <Box sx={{ mt: 2, display: 'flex', justifyContent: 'center', gap: 1 }}>
          {backendStatus && (
            <>
              <Chip
                label={`Status: ${backendStatus.status === 'healthy' ? 'Online' : 'Offline'}`}
                color={backendStatus.status === 'healthy' ? 'success' : 'error'}
                size="small"
                sx={{ backgroundColor: 'rgba(255,255,255,0.2)', color: 'white' }}
              />
              {backendStatus.ocr_engine && (
                <Chip
                  label={`Engine: ${backendStatus.ocr_engine.toUpperCase()}`}
                  size="small"
                  sx={{ backgroundColor: 'rgba(255,255,255,0.2)', color: 'white' }}
                />
              )}
            </>
          )}
        </Box>
      </Paper>

      {/* Backend Offline Warning */}
      {backendStatus?.status === 'offline' && (
        <Alert severity="warning" sx={{ mb: 3 }}>
          Backend server is not reachable. Please ensure the backend is running at{' '}
          <strong>{import.meta.env.VITE_API_BASE_URL || 'http://localhost:8080/api'}</strong>
        </Alert>
      )}

      {/* Upload Section */}
      <Paper elevation={3} sx={{ p: 4, mb: 3 }}>
        <Typography variant="h5" component="h2" gutterBottom sx={{ mb: 3 }}>
          Upload Image
        </Typography>
        <ImageUpload onUpload={handleUpload} loading={loading} />
      </Paper>

      {/* Results Section */}
      <ResultDisplay result={result} error={error} />

      {/* Snackbar for notifications */}
      <Snackbar
        open={snackbar.open}
        autoHideDuration={4000}
        onClose={handleCloseSnackbar}
        anchorOrigin={{ vertical: 'bottom', horizontal: 'center' }}
      >
        <Alert onClose={handleCloseSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
          {snackbar.message}
        </Alert>
      </Snackbar>

      {/* Footer */}
      <Box sx={{ mt: 4, textAlign: 'center' }}>
        <Typography variant="body2" color="text.secondary">
          Supports JPG/JPEG images up to 10MB • Powered by Google Cloud Vision & Tesseract OCR
        </Typography>
      </Box>
    </Box>
  );
};

export default OCRPage;
