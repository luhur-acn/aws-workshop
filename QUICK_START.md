# Quick Start Guide for Beginners

## 🎯 5-Minute Setup

### Step 1: Prepare Your EC2 Instance

Log into your AWS Console and:
1. Launch a new **Ubuntu 20.04 LTS** t2.micro instance
2. Create a new key pair (save the .pem file)
3. Edit the security group to allow:
   - SSH (22)
   - HTTP (80)
   - Custom TCP (5000)

### Step 2: Connect to Your Instance

On your local machine:
```bash
chmod 400 your-key.pem
ssh -i your-key.pem ubuntu@YOUR_PUBLIC_IP
```

Replace `YOUR_PUBLIC_IP` with the instance's public IP from AWS console.

### Step 3: Download the Project

```bash
# Clone the repository (if using git)
git clone https://github.com/YOUR_USERNAME/hands-on-workshop.git
cd hands-on-workshop

# Or use wget to download a zip file if available
```

### Step 4: Run the Deployment Script

```bash
chmod +x deploy.sh
./deploy.sh
```

This single command will:
- ✓ Install Node.js
- ✓ Install dependencies
- ✓ Start the backend (port 5000)
- ✓ Start the frontend (port 80)

**Wait 30 seconds for services to start...**

### Step 5: Open Your App

In your browser, go to:
```
http://YOUR_PUBLIC_IP
```

You should see a beautiful personal profile page! 🎉

## ✅ Verify It's Working

1. **Check backend health:**
   ```bash
   curl http://localhost:5000/api/health
   ```
   You should see: `{"status":"ok","message":"Backend is running on AWS EC2!"}`

2. **Check service status:**
   ```bash
   sudo systemctl status workshop-backend.service
   sudo systemctl status workshop-frontend.service
   ```
   Both should show "active (running)"

3. **Test the app:**
   - Open the profile page in your browser
   - Edit your profile information
   - Like the profile with a visitor name
   - See the likes count update in real-time

## 🆘 Troubleshooting

### "Connection refused" on port 5000?

Check if the backend is running:
```bash
sudo systemctl restart workshop-backend.service
sudo journalctl -u workshop-backend.service -n 20
```

### "Page not found" error on frontend?

Check if the frontend service is running:
```bash
sudo systemctl restart workshop-frontend.service
sudo journalctl -u workshop-frontend.service -n 20
```

### Can't see your public IP?

In AWS Console → Instances → Select your instance → Scroll right to find "Public IPv4 address"

### Still having issues?

1. Check security group allows ports 80 and 5000
2. Verify instance is running (green status)
3. Wait 2-3 minutes for services to fully start
4. Try restarting services: `sudo systemctl restart workshop-backend.service`

## 📝 Next Steps

Once your app is working:

1. **Customize the Todo App**
   - Edit `frontend/index.html` to change the design
   - Edit `backend/app.js` to add new features

2. **Add a Database**
   - Currently todos are in-memory (lost on restart)
   - Add SQLite, PostgreSQL, or MongoDB for persistence

3. **Deploy to Your Own Domain**
   - Use Route 53 to point a domain to your EC2 IP
   - Add SSL certificate with AWS Certificate Manager

4. **Learn More**
   - Study how the backend API works
   - Understand the frontend JavaScript
   - Practice modifying the code

## 💡 Key Concepts You're Learning

✅ **AWS EC2** - Virtual machines in the cloud
✅ **SSH** - Secure shell to connect to servers
✅ **Services/Systemd** - Keeping apps running automatically
✅ **REST APIs** - How frontend and backend communicate
✅ **Full Stack** - Building both frontend and backend
✅ **Deployment** - Getting code running in production

## 🎓 What to Try Next

1. **Edit your profile** - Customize name, title, bio, and links
2. **Like your own profile** - See the likes counter increase
3. **Modify the styling** - Edit CSS in `frontend/index.html`
4. **Add a database** - Replace in-memory storage with persistent data
5. **Deploy multiple versions** - Launch a second EC2 instance

---

**Congratulations! You've deployed a full-stack app on AWS! 🚀**

For more details, see [README.md](README.md)
