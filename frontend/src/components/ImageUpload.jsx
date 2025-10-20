import React, { useState, useRef } from 'react';
import {
  Box,
  Button,
  Paper,
  Typography,
  CircularProgress,
  Alert,
} from '@mui/material';
import CloudUploadIcon from '@mui/icons-material/CloudUpload';
import ImageIcon from '@mui/icons-material/Image';

const ImageUpload = ({ onUpload, loading }) => {
  const [selectedFile, setSelectedFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [error, setError] = useState('');
  const fileInputRef = useRef(null);

  const validateFile = (file) => {
    // Check file type
    const allowedTypes = ['image/jpeg', 'image/jpg'];
    if (!allowedTypes.includes(file.type)) {
      return 'Only JPG/JPEG files are allowed';
    }

    // Check file size (10MB max)
    const maxSize = 10 * 1024 * 1024; // 10MB in bytes
    if (file.size > maxSize) {
      return 'File size must be less than 10MB';
    }

    return null;
  };

  const handleFileSelect = (event) => {
    const file = event.target.files[0];
    if (!file) return;

    const validationError = validateFile(file);
    if (validationError) {
      setError(validationError);
      setSelectedFile(null);
      setPreview(null);
      return;
    }

    setError('');
    setSelectedFile(file);

    // Create preview
    const reader = new FileReader();
    reader.onloadend = () => {
      setPreview(reader.result);
    };
    reader.readAsDataURL(file);
  };

  const handleUpload = () => {
    if (selectedFile) {
      onUpload(selectedFile);
    }
  };

  const handleDrop = (event) => {
    event.preventDefault();
    const file = event.dataTransfer.files[0];
    if (file) {
      const validationError = validateFile(file);
      if (validationError) {
        setError(validationError);
        return;
      }

      setError('');
      setSelectedFile(file);

      const reader = new FileReader();
      reader.onloadend = () => {
        setPreview(reader.result);
      };
      reader.readAsDataURL(file);
    }
  };

  const handleDragOver = (event) => {
    event.preventDefault();
  };

  const handleClear = () => {
    setSelectedFile(null);
    setPreview(null);
    setError('');
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <Box>
      <Paper
        elevation={3}
        sx={{
          p: 4,
          textAlign: 'center',
          border: '2px dashed',
          borderColor: error ? 'error.main' : 'primary.main',
          backgroundColor: 'background.paper',
          cursor: 'pointer',
          transition: 'all 0.3s',
          '&:hover': {
            borderColor: error ? 'error.dark' : 'primary.dark',
            backgroundColor: 'action.hover',
          },
        }}
        onDrop={handleDrop}
        onDragOver={handleDragOver}
        onClick={() => fileInputRef.current?.click()}
      >
        <input
          ref={fileInputRef}
          type="file"
          accept="image/jpeg,image/jpg"
          onChange={handleFileSelect}
          style={{ display: 'none' }}
        />

        {preview ? (
          <Box>
            <img
              src={preview}
              alt="Preview"
              style={{
                maxWidth: '100%',
                maxHeight: '300px',
                borderRadius: '8px',
                marginBottom: '16px',
              }}
            />
            <Typography variant="body2" color="text.secondary">
              {selectedFile.name} ({(selectedFile.size / 1024).toFixed(2)} KB)
            </Typography>
          </Box>
        ) : (
          <Box>
            <ImageIcon sx={{ fontSize: 64, color: 'primary.main', mb: 2 }} />
            <Typography variant="h6" gutterBottom>
              Drag & Drop or Click to Upload
            </Typography>
            <Typography variant="body2" color="text.secondary">
              JPG/JPEG only • Max 10MB
            </Typography>
          </Box>
        )}
      </Paper>

      {error && (
        <Alert severity="error" sx={{ mt: 2 }}>
          {error}
        </Alert>
      )}

      <Box sx={{ mt: 3, display: 'flex', gap: 2, justifyContent: 'center' }}>
        {selectedFile && (
          <>
            <Button
              variant="outlined"
              onClick={handleClear}
              disabled={loading}
            >
              Clear
            </Button>
            <Button
              variant="contained"
              startIcon={loading ? <CircularProgress size={20} /> : <CloudUploadIcon />}
              onClick={handleUpload}
              disabled={loading || !selectedFile}
              size="large"
            >
              {loading ? 'Processing...' : 'Extract Text'}
            </Button>
          </>
        )}
      </Box>
    </Box>
  );
};

export default ImageUpload;
