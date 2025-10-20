import React from 'react';
import {
  Box,
  Paper,
  Typography,
  Chip,
  Divider,
  Alert,
  IconButton,
  Tooltip,
} from '@mui/material';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import CheckCircleIcon from '@mui/icons-material/CheckCircle';
import SpeedIcon from '@mui/icons-material/Speed';
import VisibilityIcon from '@mui/icons-material/Visibility';
import SettingsIcon from '@mui/icons-material/Settings';

const ResultDisplay = ({ result, error }) => {
  const [copied, setCopied] = React.useState(false);

  const handleCopy = () => {
    navigator.clipboard.writeText(result.text);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (error) {
    return (
      <Paper elevation={3} sx={{ p: 3, mt: 3 }}>
        <Alert severity="error">
          <Typography variant="h6" gutterBottom>
            Error
          </Typography>
          <Typography variant="body2">{error}</Typography>
        </Alert>
      </Paper>
    );
  }

  if (!result) {
    return null;
  }

  const getConfidenceColor = (confidence) => {
    if (confidence >= 0.8) return 'success';
    if (confidence >= 0.6) return 'warning';
    return 'error';
  };

  return (
    <Paper elevation={3} sx={{ p: 3, mt: 3 }}>
      <Box sx={{ display: 'flex', alignItems: 'center', mb: 2 }}>
        <CheckCircleIcon sx={{ color: 'success.main', mr: 1 }} />
        <Typography variant="h5" component="h2">
          Extraction Results
        </Typography>
      </Box>

      <Divider sx={{ mb: 2 }} />

      {/* Metadata */}
      <Box sx={{ display: 'flex', gap: 2, mb: 3, flexWrap: 'wrap' }}>
        <Chip
          icon={<SettingsIcon />}
          label={`Engine: ${result.ocr_engine.toUpperCase()}`}
          color="primary"
          variant="outlined"
        />
        <Chip
          icon={<VisibilityIcon />}
          label={`Confidence: ${(result.confidence * 100).toFixed(0)}%`}
          color={getConfidenceColor(result.confidence)}
          variant="outlined"
        />
        <Chip
          icon={<SpeedIcon />}
          label={`${result.processing_time_ms}ms`}
          color="secondary"
          variant="outlined"
        />
      </Box>

      {/* Extracted Text */}
      <Box sx={{ position: 'relative' }}>
        <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 1 }}>
          <Typography variant="h6" component="h3">
            Extracted Text
          </Typography>
          <Tooltip title={copied ? 'Copied!' : 'Copy to clipboard'}>
            <IconButton onClick={handleCopy} size="small" color="primary">
              <ContentCopyIcon />
            </IconButton>
          </Tooltip>
        </Box>

        <Paper
          variant="outlined"
          sx={{
            p: 2,
            backgroundColor: 'grey.50',
            maxHeight: '400px',
            overflow: 'auto',
          }}
        >
          {result.text ? (
            <Typography
              variant="body1"
              component="pre"
              sx={{
                whiteSpace: 'pre-wrap',
                wordBreak: 'break-word',
                fontFamily: 'monospace',
                margin: 0,
              }}
            >
              {result.text}
            </Typography>
          ) : (
            <Typography variant="body2" color="text.secondary" fontStyle="italic">
              No text detected in the image
            </Typography>
          )}
        </Paper>

        {result.text && (
          <Typography variant="caption" color="text.secondary" sx={{ mt: 1, display: 'block' }}>
            {result.text.length} characters • {result.text.split(/\s+/).filter(Boolean).length} words
          </Typography>
        )}
      </Box>
    </Paper>
  );
};

export default ResultDisplay;
