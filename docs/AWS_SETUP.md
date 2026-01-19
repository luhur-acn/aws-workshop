# AWS EC2 Setup Guide

Complete step-by-step guide to set up your EC2 instance for the workshop.

## 📊 Prerequisites

- AWS account (free tier eligible)
- A web browser
- An SSH client (built-in on Mac/Linux, PuTTY on Windows)

## 🔑 Step 1: Create an EC2 Instance

### 1.1 Open AWS Console

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Log in to your AWS Console
3. Search for "EC2" in the top search bar
4. Click "EC2" under Services

### 1.2 Launch an Instance

1. Click **"Launch Instance"** button
2. Choose **"Ubuntu Server 20.04 LTS"** (free tier eligible)
3. Select instance type **t2.micro** (free tier)
4. Click **"Review and Launch"**

### 1.3 Configure Security

1. Click **"Edit security groups"** (or skip to next steps)
2. Add the following rules:
   ```
   Type          Protocol  Port Range  Source
   SSH           TCP       22          0.0.0.0/0
   HTTP          TCP       80          0.0.0.0/0
   HTTPS         TCP       443         0.0.0.0/0
   ```
   (Note: 0.0.0.0/0 means anywhere - fine for learning, restrict in production)

### 1.4 Create Key Pair

1. Under "Key Pair", click **"Create new key pair"**
2. Name it: `my-workshop-key`
3. Choose **"pem"** format
4. Click **"Download"** - Save this file somewhere safe!
5. Click **"Launch Instance"**

## 🎯 Step 2: Connect to Your Instance

### 2.1 Wait for Instance to Start

1. Go back to the EC2 Dashboard
2. Click **"Instances"** (on the left)
3. Find your new instance
4. Wait until Status is **"running"** (green circle)

### 2.2 Note the Public IP

1. Find your instance in the list
2. Scroll right or look for "Public IPv4 address"
3. Copy this IP address (e.g., `54.123.45.67`)

### 2.3 SSH Connection (Mac/Linux)

Open Terminal and run:

```bash
# Navigate to where you downloaded the key
cd ~/Downloads

# Set correct permissions
chmod 400 my-workshop-key.pem

# Connect to EC2
ssh -i my-workshop-key.pem ubuntu@54.123.45.67
```

Replace `54.123.45.67` with your actual public IP.

### 2.3 SSH Connection (Windows)

Using PuTTY:

1. Download PuTTY from [putty.org](https://putty.org)
2. Open PuTTYgen
3. File → Load private key → Select your `.pem` file
4. Save private key as `.ppk`
5. Open PuTTY and:
   - Host: `ubuntu@54.123.45.67`
   - Connection → SSH → Auth → Select `.ppk` file
   - Click Open

## ✅ Step 3: Prepare for Deployment

Once connected to your EC2 instance:

### 3.1 Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

### 3.2 Download Project

Option A - Using Git:
```bash
sudo apt-get install git -y
git clone https://github.com/YOUR_USERNAME/hands-on-workshop.git
cd hands-on-workshop
```

Option B - Upload files via SCP:
```bash
# From your local machine
scp -i my-workshop-key.pem -r ./hands-on-workshop \
  ubuntu@54.123.45.67:~/
```

Option C - Download as ZIP:
```bash
wget https://github.com/YOUR_USERNAME/hands-on-workshop/archive/main.zip
unzip main.zip
cd hands-on-workshop-main
```

## 🚀 Step 4: Deploy the App

### 4.1 Run Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

This will take 2-3 minutes. You'll see:
- System packages being installed
- Node.js being installed
- Dependencies being installed
- Services starting up

### 4.2 Wait for Completion

When you see this, you're done:
```
================================
✓ Deployment Complete!
================================

📱 Frontend: http://54.123.45.67
🔗 Backend API: http://54.123.45.67:443/api
```

## 🌐 Step 5: Access Your App

1. Open a new browser tab
2. Go to: `http://YOUR_PUBLIC_IP`
3. You should see your Todo App! 🎉

## 🔧 Troubleshooting

### Connection Timed Out?

- Check AWS Console → Security Groups
- Make sure SSH (port 22) is allowed from your IP
- Try waiting 5 minutes for instance to fully boot

### Deploy Script Fails?

```bash
# Check what went wrong
sudo journalctl -u workshop-backend.service -n 50
sudo journalctl -u workshop-frontend.service -n 50
```

### Can't Connect via SSH?

1. Verify you're using the correct public IP
2. Check key pair is downloaded correctly
3. Verify key pair has correct permissions: `chmod 400 my-workshop-key.pem`
4. Try connecting with verbose output: `ssh -v -i my-workshop-key.pem ubuntu@54.123.45.67`

### App Shows "Cannot Connect to Backend"?

1. Check ports are open in security group
2. Check backend service is running:
   ```bash
   sudo systemctl status workshop-backend.service
   ```
3. Check for errors:
   ```bash
   sudo journalctl -u workshop-backend.service -f
   ```

## 💰 Monitoring Costs

Free tier includes:
- ✓ 750 hours of t2.micro per month
- ✓ 30GB of storage per month
- ✓ 15GB of data transfer

**Tip:** Stop instances when not using them to save hours.

To stop an instance:
1. AWS Console → Instances
2. Right-click instance → Instance State → Stop
3. To restart: Instance State → Start

## 🧹 Cleanup (When Done)

To avoid unexpected charges:

1. AWS Console → Instances
2. Right-click your instance
3. Instance State → Terminate
4. Confirm termination

This will delete:
- The EC2 instance
- The associated storage
- Any data on the instance

## 📚 Next Steps

1. **Customize your app** - Modify the code
2. **Add a database** - Replace in-memory storage
3. **Set up a domain** - Use Route 53
4. **Add HTTPS** - Use AWS Certificate Manager
5. **Scale your app** - Use Auto Scaling Groups

## 🆘 Getting Help

- AWS Documentation: https://docs.aws.amazon.com/ec2/
- AWS Free Tier FAQ: https://aws.amazon.com/free/
- AWS Support: https://console.aws.amazon.com/support/

---

**You've successfully deployed your first app on AWS! 🚀**
