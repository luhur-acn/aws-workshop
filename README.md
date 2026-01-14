# AWS Workshop - Personal Profile Website

A beginner-friendly full-stack personal profile application with a likes feature, designed to teach AWS EC2 deployment concepts.

## 📋 What's Included

- **Backend**: Node.js API with profile management and likes tracking
- **Frontend**: Beautiful personal profile with edit and like functionality
- **Deployment**: Single script to automate everything

## 🏗️ Architecture

```
┌─────────────────┐         ┌──────────────────┐
│  Frontend       │         │  Backend API     │
│  (Port 80)      │◄───────►│  (Port 5000)     │
│  HTML/CSS/JS    │         │  Node.js/HTTP    │
└─────────────────┘         └──────────────────┘
    EC2 Instance
```

## ⚡ Quick Start

### Prerequisites

- AWS EC2 instance (Ubuntu 20.04 or later)
- SSH access to the instance
- Security group allowing ports 80 and 5000

### 1. Connect to EC2 Instance

```bash
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

### 2. Clone or Upload Project

Option A: Using Git (if available)
```bash
git clone <your-repo-url>
cd hands-on-workshop
```

Option B: Upload files directly
```bash
scp -i your-key.pem -r ./hands-on-workshop ec2-user@YOUR_EC2_PUBLIC_IP:~/
```

### 3. Run Deployment Script

```bash
cd hands-on-workshop
chmod +x deploy.sh
./deploy.sh
```

The script will:
- ✓ Update system packages
- ✓ Install Node.js
- ✓ Install dependencies
- ✓ Setup backend service (port 5000)
- ✓ Setup frontend service (port 80)
- ✓ Start both services automatically

### 4. Access Your App

Open your browser and navigate to:
```
http://YOUR_EC2_PUBLIC_IP
```

## 📁 Project Structure

```
hands-on-workshop/
├── backend/
│   ├── app.js              # Node.js server
│   └── package.json        # Dependencies
├── frontend/
│   └── index.html          # React-free frontend
├── deploy.sh               # One-script deployment
└── README.md               # This file
```

## 🔧 What the Backend Does

The backend is a simple REST API for profile management:

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/health` | Check if backend is running |
| GET | `/api/profile` | Get profile information |
| PUT | `/api/profile` | Update profile information |
| POST | `/api/profile/like` | Like the profile |
| POST | `/api/profile/unlike` | Unlike the profile |

### Example Requests

**Health Check:**
```bash
curl http://YOUR_EC2_PUBLIC_IP:5000/api/health
```

**Get Profile:**
```bash
curl http://YOUR_EC2_PUBLIC_IP:5000/api/profile
```

**Like Profile:**
```bash
curl -X POST http://YOUR_EC2_PUBLIC_IP:5000/api/profile/like \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"John Doe"}'
```

**Update Profile:**
```bash
curl -X PUT http://YOUR_EC2_PUBLIC_IP:5000/api/profile \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Doe","title":"Developer","bio":"Hello!"}'
```

## 🖥️ Frontend Features

- ✅ Display personal profile information
- ✅ Edit profile details (name, title, bio, email, links)
- ✅ Like/Unlike the profile
- ✅ View who liked your profile
- ✅ Real-time backend status indicator
- ✅ Responsive design
- ✅ Error handling

## 🔍 Monitoring & Troubleshooting

### View Service Status

```bash
sudo systemctl status workshop-backend.service
sudo systemctl status workshop-frontend.service
```

### Check Logs

```bash
# Backend logs
sudo journalctl -u workshop-backend.service -f

# Frontend logs
sudo journalctl -u workshop-frontend.service -f

# Show last 20 lines
sudo journalctl -u workshop-backend.service -n 20
```

### Restart Services

```bash
sudo systemctl restart workshop-backend.service
sudo systemctl restart workshop-frontend.service
```

### Stop Services

```bash
sudo systemctl stop workshop-backend.service
sudo systemctl stop workshop-frontend.service
```

## 🚀 AWS EC2 Setup (if you don't have an instance yet)

### Create EC2 Instance

1. Open AWS Console → EC2 → Instances → Launch Instance
2. Choose **Ubuntu Server 20.04 LTS** (free tier eligible)
3. Instance type: **t2.micro** (free tier)
4. Configure security group:
   - Allow SSH (port 22)
   - Allow HTTP (port 80)
   - Allow Custom TCP (port 5000)
5. Create/select key pair and launch

### Wait for Instance to Run

- Status should show "running"
- Note the Public IP address

### Connect via SSH

```bash
chmod 400 your-key.pem
ssh -i your-key.pem ec2-user@YOUR_EC2_PUBLIC_IP
```

## 📝 Environment Variables

The deployment script sets these automatically:

```bash
PORT=5000              # Backend port
NODE_ENV=production    # Node.js environment
```

To modify them, edit `/etc/systemd/system/workshop-backend.service`:

```bash
sudo nano /etc/systemd/system/workshop-backend.service
# Edit the [Service] section
sudo systemctl daemon-reload
sudo systemctl restart workshop-backend.service
```

## 🔐 Security Notes

⚠️ **This is a demo app!** For production:

- [ ] Add authentication
- [ ] Use HTTPS/SSL
- [ ] Validate all inputs
- [ ] Use a database instead of in-memory storage
- [ ] Implement rate limiting
- [ ] Add CORS restrictions (update `ALLOWED_ORIGINS`)

## 💾 Data Persistence

Currently, profile and likes are stored **in memory** and will be lost when the service restarts.

To persist data, modify the backend to use a database:
- SQLite (lightweight)
- PostgreSQL (recommended)
- MongoDB (NoSQL)

## 🛑 Uninstall

Remove the deployed services:

```bash
sudo systemctl stop workshop-backend.service
sudo systemctl stop workshop-frontend.service
sudo systemctl disable workshop-backend.service
sudo systemctl disable workshop-frontend.service
sudo rm /etc/systemd/system/workshop-backend.service
sudo rm /etc/systemd/system/workshop-frontend.service
sudo systemctl daemon-reload
```

## 📚 Learning Resources

- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Node.js Guide](https://nodejs.org/en/docs/)
- [REST API Design](https://restfulapi.net/)

## 🤝 Support

If you encounter issues:

1. Check service status: `sudo systemctl status workshop-backend.service`
2. View logs: `sudo journalctl -u workshop-backend.service -n 50`
3. Verify ports are open: `sudo netstat -tlnp` or `ss -tlnp`
4. Check security group in AWS Console

## 📄 License

MIT License - Feel free to modify and use for learning!

---

**Happy Learning! 🚀**
