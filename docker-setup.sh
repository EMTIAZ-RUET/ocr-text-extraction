#!/bin/bash

echo "🐳 Docker Compose Setup for OCR Application"
echo "============================================"

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Check for Google Cloud credentials
if [ ! -f "./credentials.json" ]; then
    echo "⚠️  Google Cloud credentials not found!"
    echo ""
    echo "📋 To use Google Cloud Vision API:"
    echo "1. Go to Google Cloud Console"
    echo "2. Create a service account with Vision API access"
    echo "3. Download the JSON key file"
    echo "4. Save it as 'credentials.json' in this directory"
    echo ""
    echo "🔄 For now, you can still run the application without OCR functionality"
    echo ""
fi

# Create .env file for Docker Compose if it doesn't exist
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file for Docker Compose..."
    cat > .env << 'EOF'
# OCR Configuration
OCR_ENGINE=google
LOG_LEVEL=INFO

# Google Cloud Vision API
GOOGLE_APPLICATION_CREDENTIALS=/app/credentials.json

# API URLs
BACKEND_URL=http://localhost:8080
FRONTEND_URL=http://localhost:3000
EOF
    echo "✅ Created .env file"
fi

echo ""
echo "🚀 Starting OCR Application with Docker Compose..."
echo ""

# Build and start services
docker-compose up --build -d

echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Check service status
echo "📊 Service Status:"
docker-compose ps

echo ""
echo "🎉 OCR Application is running!"
echo ""
echo "🌐 Access URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend API: http://localhost:8080"
echo "  API Docs: http://localhost:8080/docs"
echo "  Health Check: http://localhost:8080/api/health"
echo ""
echo "🧪 Test the API:"
echo "  curl -X POST \"http://localhost:8080/api/extract-text\" -F \"file=@test_image.jpg\""
echo ""
echo "🛑 To stop the application:"
echo "  docker-compose down"
echo ""
echo "📋 To view logs:"
echo "  docker-compose logs -f"
