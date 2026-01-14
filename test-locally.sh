#!/bin/bash

#########################################################
# Local Testing Script - Test before deploying to AWS
#########################################################

echo "================================"
echo "🧪 AWS Workshop - Local Test"
echo "================================"

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
  echo "❌ Node.js is not installed"
  echo "Please install Node.js first: https://nodejs.org/"
  exit 1
fi

echo "✓ Node.js version: $(node --version)"

# Navigate to backend
cd "$(dirname "$0")/backend"

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo ""
  echo "📦 Installing backend dependencies..."
  npm install
fi

# Start backend
echo ""
echo "🚀 Starting backend on port 5000..."
node app.js &
BACKEND_PID=$!

# Wait for backend to start
sleep 2

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
  echo "❌ Backend failed to start"
  exit 1
fi

echo "✓ Backend is running (PID: $BACKEND_PID)"

# Test health endpoint
echo ""
echo "🔍 Testing health endpoint..."
HEALTH=$(curl -s http://localhost:5000/api/health)
echo "Response: $HEALTH"

# Test todos endpoint
echo ""
echo "🔍 Testing todos endpoint..."
TODOS=$(curl -s http://localhost:5000/api/todos)
echo "Response: $TODOS"

# Open frontend
echo ""
echo "📱 Opening frontend at http://localhost:3000"
echo "Serving frontend from: $(pwd)/../frontend"

# Start simple HTTP server for frontend
cd ../frontend
python3 -m http.server 3000 &
FRONTEND_PID=$!

echo "✓ Frontend is running (PID: $FRONTEND_PID)"

echo ""
echo "================================"
echo "✅ Everything is ready!"
echo "================================"
echo ""
echo "Frontend: http://localhost:3000"
echo "Backend:  http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop both services..."
echo ""

# Trap to clean up on exit
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; echo ''; echo 'Services stopped'; exit" INT TERM

# Keep the script running
wait
