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
- Docker & Docker Compose (recommended)
- OR Python 3.11+ & Node.js 18+ (for manual setup)
- Google Cloud Account (for Vision API)

### 🐳 **Easy Setup with Docker Compose (Recommended)**

1. **Clone the repository**
```bash
git clone https://github.com/EMTIAZ-RUET/ocr-text-extraction.git
cd ocr-text-extraction
```

2. **Add Google Cloud Credentials (Optional)**
```bash
# Place your service account key file as 'credentials.json'
# Skip this step to run without OCR functionality
```

3. **Start the application**
```bash
./docker-setup.sh
```

**That's it!** The application will be available at:
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8080
- **API Docs**: http://localhost:8080/docs

### 🔧 **Manual Local Development**

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

## 🐳 Docker Compose Commands

### Start the application
```bash
# Start all services
docker-compose up -d

# Start with build (if you made changes)
docker-compose up --build -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Individual service management
```bash
# Start only backend
docker-compose up backend -d

# Restart frontend
docker-compose restart frontend

# View backend logs
docker-compose logs backend
```

### Troubleshooting
```bash
# Check service status
docker-compose ps

# Rebuild specific service
docker-compose build backend

# Remove all containers and volumes
docker-compose down -v
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
│   ├── Dockerfile          # Frontend container
│   └── src/               # React source code
├── docker-compose.yml     # Docker Compose configuration
├── docker-setup.sh        # Easy Docker setup script
├── test_image.jpg         # Sample test image
├── credentials.json       # Google Cloud credentials (add this)
└── deploy-*.sh           # Cloud deployment scripts
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
