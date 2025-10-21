# OCR Image Text Extraction API

A serverless OCR API that extracts text from JPG/JPEG images using Google Cloud Vision API. Built with FastAPI and optimized for Google Cloud Run deployment.

## Features

- **JPG/JPEG Image Processing**: Upload images via REST API
- **Google Cloud Vision OCR**: High-accuracy text extraction
- **JSON Response**: Structured output with confidence scores
- **Error Handling**: Comprehensive validation and error responses
- **Cloud Run Ready**: Containerized for serverless deployment

## Quick Start

### Prerequisites
- Python 3.11+
- Google Cloud Account (for Vision API)
- Docker (optional)

### Local Development

1. **Install Dependencies**
```bash
cd backend
pip install -r requirements.txt
```

2. **Set Google Cloud Credentials**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"
```

3. **Run the API**
```bash
python main.py
```

API runs at: `http://localhost:8080`

### Test the API

```bash
# Health check
curl http://localhost:8080/api/health

# Extract text from image
curl -X POST "http://localhost:8080/api/extract-text" \
  -F "file=@test_image.jpg"
```

## API Endpoints

### POST /api/extract-text
Extract text from uploaded JPG/JPEG image.

**Request:**
- Method: POST
- Content-Type: multipart/form-data
- Body: file (JPG/JPEG, max 10MB)

**Response:**
```json
{
  "success": true,
  "ocr_engine": "google",
  "text": "extracted text content",
  "confidence": 0.95,
  "processing_time_ms": 1234
}
```

### GET /api/health
Health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "ocr_engine": "google"
}
```

## Google Cloud Run Deployment

### Deploy Backend

```bash
# Set your project ID
export PROJECT_ID="your-gcp-project-id"

# Deploy using the provided script
PROJECT_ID=$PROJECT_ID ./deploy-backend.sh
```

### Deploy Frontend

```bash
# Get backend URL from previous step
export BACKEND_URL="https://your-backend-url"

# Deploy frontend
PROJECT_ID=$PROJECT_ID BACKEND_URL=$BACKEND_URL ./deploy-frontend.sh
```

## Project Structure

```
├── backend/                 # FastAPI Backend
│   ├── main.py             # Application entry point
│   ├── config.py           # Configuration
│   ├── requirements.txt    # Dependencies
│   ├── Dockerfile          # Container config
│   └── app/
│       ├── routes/
│       │   └── ocr_routes.py    # API endpoints
│       └── services/
│           └── ocr_google.py    # Google Vision OCR
├── frontend/               # React Frontend
├── test_image.jpg         # Sample test image
└── deploy-*.sh           # Deployment scripts
```

## Configuration

Edit `backend/config.py`:

| Setting | Description | Default |
|---------|-------------|---------|
| `MAX_FILE_SIZE_MB` | Max upload size | 10 |
| `ALLOWED_EXTENSIONS` | File types | {"jpg", "jpeg"} |
| `LOG_LEVEL` | Logging level | "INFO" |

## Error Handling

- **400**: Invalid file type, size, or format
- **500**: Server error during processing
- **422**: Missing or invalid request data

## Requirements Met

✅ JPG image upload API  
✅ OCR text extraction  
✅ JSON response format  
✅ Error handling  
✅ Cloud Run deployment  
✅ 10MB file limit  
✅ Sample test image  
✅ Complete documentation  

## License

MIT License
