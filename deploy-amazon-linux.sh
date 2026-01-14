#!/bin/bash

#########################################################
# AWS Workshop - Amazon Linux Deployment Script
# For Amazon Linux 2 and Amazon Linux 2023
# Run this script on your EC2 instance to deploy
#########################################################

set -e  # Exit on error

echo "================================"
echo "🚀 AWS Workshop App Deployment"
echo "   (Amazon Linux)"
echo "================================"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root for installation
if [ "$EUID" -ne 0 ]; then 
  echo -e "${YELLOW}Note: Some commands may require sudo${NC}"
fi

# Detect Amazon Linux version
if grep -q "Amazon Linux 2023" /etc/os-release; then
  echo -e "${YELLOW}Detected: Amazon Linux 2023${NC}"
  PKG_MANAGER="dnf"
elif grep -q "Amazon Linux 2" /etc/os-release; then
  echo -e "${YELLOW}Detected: Amazon Linux 2${NC}"
  PKG_MANAGER="yum"
else
  echo -e "${YELLOW}Amazon Linux version unknown, using yum${NC}"
  PKG_MANAGER="yum"
fi

# Step 1: Update system
echo -e "\n${YELLOW}[1/5] Updating system packages...${NC}"
sudo $PKG_MANAGER update -y
sudo $PKG_MANAGER upgrade -y

# Step 2: Install Node.js
echo -e "\n${YELLOW}[2/5] Installing Node.js and npm...${NC}"
if ! command -v node &> /dev/null; then
  # Enable Node.js repository
  sudo $PKG_MANAGER install -y nodejs
else
  echo "Node.js already installed: $(node --version)"
fi

# Verify npm is installed
if ! command -v npm &> /dev/null; then
  echo -e "${YELLOW}Installing npm...${NC}"
  sudo $PKG_MANAGER install -y npm
fi

# Step 3: Install dependencies
echo -e "\n${YELLOW}[3/5] Installing backend dependencies...${NC}"
cd "$(dirname "$0")/backend"
npm install
cd ..

echo -e "${GREEN}✓ Dependencies installed${NC}"

# Step 4: Create systemd service for backend
echo -e "\n${YELLOW}[4/5] Setting up backend service...${NC}"
BACKEND_DIR="$(cd "$(dirname "$0")/backend" && pwd)"
FRONTEND_DIR="$(cd "$(dirname "$0")/frontend" && pwd)"

sudo tee /etc/systemd/system/workshop-backend.service > /dev/null <<EOF
[Unit]
Description=AWS Workshop Backend Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$BACKEND_DIR
ExecStart=/usr/bin/node $BACKEND_DIR/app.js
Restart=always
RestartSec=10
Environment="PORT=5000"
Environment="NODE_ENV=production"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable workshop-backend.service
sudo systemctl restart workshop-backend.service

echo -e "${GREEN}✓ Backend service created and started${NC}"

# Step 5: Setup frontend with simple HTTP server
echo -e "\n${YELLOW}[5/5] Setting up frontend service...${NC}"

# Check if python3 is installed
if ! command -v python3 &> /dev/null; then
  echo -e "${YELLOW}Installing Python3...${NC}"
  sudo $PKG_MANAGER install -y python3
fi

# Create frontend service
sudo tee /etc/systemd/system/workshop-frontend.service > /dev/null <<EOF
[Unit]
Description=AWS Workshop Frontend Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=$FRONTEND_DIR
ExecStart=/usr/bin/python3 -m http.server 80
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable workshop-frontend.service
sudo systemctl restart workshop-frontend.service

echo -e "${GREEN}✓ Frontend service created and started${NC}"

# Step 6: Verification
echo -e "\n${YELLOW}Verifying services...${NC}"

sleep 2

if sudo systemctl is-active --quiet workshop-backend.service; then
  echo -e "${GREEN}✓ Backend service is running${NC}"
else
  echo -e "${RED}✗ Backend service failed to start${NC}"
  sudo journalctl -u workshop-backend.service -n 20
  exit 1
fi

if sudo systemctl is-active --quiet workshop-frontend.service; then
  echo -e "${GREEN}✓ Frontend service is running${NC}"
else
  echo -e "${RED}✗ Frontend service failed to start${NC}"
  sudo journalctl -u workshop-frontend.service -n 20
  exit 1
fi

# Get the public IP (try IMDSv2 first, fall back to IMDSv1)
PUBLIC_IP=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" 2>/dev/null | xargs -I {} curl -s -H "X-aws-ec2-metadata-token: {}" "http://169.254.169.254/latest/meta-data/public-ipv4" 2>/dev/null || curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "YOUR_EC2_PUBLIC_IP")

# If IP detection failed, try hostname
if [ "$PUBLIC_IP" = "YOUR_EC2_PUBLIC_IP" ]; then
  PUBLIC_IP=$(hostname -I | awk '{print $1}')
  if [ "$PUBLIC_IP" = "127.0.0.1" ] || [ -z "$PUBLIC_IP" ]; then
    PUBLIC_IP="YOUR_EC2_PUBLIC_IP"
  fi
fi

# Print success message
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}✓ Deployment Complete!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo "📱 Frontend: http://$PUBLIC_IP"
echo "🔗 Backend API: http://$PUBLIC_IP:5000/api"
echo "💚 Health Check: http://$PUBLIC_IP:5000/api/health"
echo ""
echo "📋 Useful Commands:"
echo "   View backend logs: sudo journalctl -u workshop-backend.service -f"
echo "   View frontend logs: sudo journalctl -u workshop-frontend.service -f"
echo "   Restart backend: sudo systemctl restart workshop-backend.service"
echo "   Restart frontend: sudo systemctl restart workshop-frontend.service"
echo "   View service status: sudo systemctl status workshop-backend.service"
echo ""
echo "🎉 Your app is live!"
