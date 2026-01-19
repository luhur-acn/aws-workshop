# Architecture Overview

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  AWS EC2 Instance (Ubuntu)              │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │          Systemd (Service Manager)               │   │
│  │                                                   │   │
│  │  ┌──────────────────┐    ┌─────────────────────┐ │   │
│  │  │   Frontend       │    │  Backend            │ │   │
│  │  │   Service        │    │  Service            │ │   │
│  │  │                  │    │                     │ │   │
│  │  │ HTTP Server      │    │ Node.js             │ │   │
│  │  │ (Port 80)        │    │ (Port 443)         │ │   │
│  │  │                  │◄───►│ /api/todos          │ │   │
│  │  │ index.html       │    │ /api/health         │ │   │
│  │  │ CSS, JavaScript  │    │ REST API            │ │   │
│  │  └──────────────────┘    └─────────────────────┘ │   │
│  │           ▲                                      │   │
│  │           │                                      │   │
│  │  ┌────────┴─────────┐                           │   │
│  │  │                  │                           │   │
│  │  │    Network       │                           │   │
│  │  │   (localhost)    │                           │   │
│  │  │                  │                           │   │
│  │  └──────────────────┘                           │   │
│  └──────────────────────────────────────────────────┘   │
│                        ▲                                 │
│                        │ SSH (Port 22)                  │
│                        │ HTTP (Port 80)                 │
│                        │ Custom TCP (Port 443)         │
└────────────────────────┼─────────────────────────────────┘
                         │
                 ┌───────▼────────┐
                 │  Your Computer │
                 │  or Laptop     │
                 └────────────────┘
```

## 📦 Components

### Frontend
- **Type**: Static HTML/CSS/JavaScript
- **Port**: 80 (HTTP)
- **Server**: Python's http.server
- **Files**: `frontend/index.html`
- **Responsibilities**:
  - Display personal profile information
  - Manage like/unlike functionality
  - Allow profile editing
  - Show backend status

### Backend
- **Type**: Node.js REST API
- **Port**: 443
- **Framework**: Built-in HTTP module (no Express needed for simplicity)
- **Files**: `backend/app.js`
- **Responsibilities**:
  - Handle API requests
  - Manage profile data
  - Track likes and likers
  - Return JSON responses

### Service Manager (Systemd)
- **Purpose**: Keep services running automatically
- **Handles**: Restart on failure, start on boot
- **Service Files**:
  - `/etc/systemd/system/workshop-backend.service`
  - `/etc/systemd/system/workshop-frontend.service`

## 🔄 Data Flow

### Loading the Profile
```
1. Browser loads http://YOUR_IP
2. Frontend HTML/CSS/JS loads
3. JavaScript calls: GET /api/profile
4. Backend retrieves profile from memory
5. Returns JSON object
6. JavaScript renders profile in DOM
```

### Liking a Profile
```
1. User enters their name (optional)
2. Clicks "Like This Profile" button
3. JavaScript prepares JSON: {visitorName: "John"}
4. Sends: POST /api/profile/like
5. Backend adds visitor to likedBy array
6. Increments likes counter
7. Returns updated likes count
8. Frontend rerenders with updated count
```

### Unliking a Profile
```
1. User clicks "Unlike This Profile" button
2. JavaScript sends: POST /api/profile/unlike
3. Body: {visitorName: "John"}
4. Backend removes visitor from likedBy array
5. Decrements likes counter
6. Returns updated count
7. Frontend updates display
```

### Editing Profile
```
1. User clicks "Edit Profile" button
2. Form appears with current profile data
3. User modifies fields
4. Clicks "Save"
5. JavaScript sends: PUT /api/profile
6. Body: {name, title, bio, email, github, linkedin}
7. Backend updates profile object
8. Returns updated profile
9. Frontend rerenders with new data
```

## 📊 Data Storage

Currently **in-memory**:
```javascript
let profile = {
  name: "Your Name",
  title: "Full Stack Developer",
  bio: "Welcome to my profile!",
  email: "your.email@example.com",
  github: "https://github.com/yourprofile",
  linkedin: "https://linkedin.com/in/yourprofile",
  avatar: "👤",
  likes: 0,
  likedBy: [],
  joinedDate: "2024-01-14T10:30:00Z",
  updatedAt: "2024-01-14T10:30:00Z"
}
```

**Important**: Data is lost when backend restarts!

To persist data, add:
- SQLite (file-based, included with Python)
- PostgreSQL (server-based, recommended)
- MongoDB (NoSQL, cloud-friendly)

## 🌐 Communication

### Frontend → Backend (XHR/Fetch)
```
Browser JavaScript
  ↓
Fetch API
  ↓
HTTP Request (JSON)
  ↓
Backend Node.js
```

### Backend → Frontend (JSON Response)
```
Backend Node.js
  ↓
HTTP Response (JSON)
  ↓
Fetch Promise
  ↓
JavaScript processes data
  ↓
DOM updates
```

## 🔌 Ports

| Port | Service | Protocol | Purpose |
|------|---------|----------|---------|
| 22 | SSH | SSH | Remote access |
| 80 | Frontend | HTTP | Web interface |
| 443 | Backend | HTTP | REST API |

## 🚀 Deployment

### What the Deploy Script Does

1. **System Update**
   ```bash
   sudo apt-get update
   sudo apt-get upgrade -y
   ```

2. **Install Node.js**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
   sudo apt-get install -y nodejs
   ```

3. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

4. **Create Backend Service**
   - Copies `app.js` path to systemd
   - Configures to auto-start
   - Sets environment variables

5. **Create Frontend Service**
   - Configures Python HTTP server
   - Points to `frontend` directory
   - Configures to auto-start

6. **Start Services**
   ```bash
   sudo systemctl start workshop-backend.service
   sudo systemctl start workshop-frontend.service
   ```

## 📈 Scaling Considerations

Current limitations:
- ❌ Single instance (not redundant)
- ❌ No load balancer
- ❌ No database (data lost on restart)
- ❌ No caching

To scale:
- ✅ Use AWS Auto Scaling Group
- ✅ Add Application Load Balancer
- ✅ Use RDS for database
- ✅ Add CloudFront CDN
- ✅ Use ElastiCache for caching

## 🔐 Security

Current security level: **Development only**

To production-ready:
- [ ] Add authentication (JWT, OAuth)
- [ ] Validate all inputs
- [ ] Use HTTPS/SSL
- [ ] Add rate limiting
- [ ] Restrict CORS origins
- [ ] Use security groups properly
- [ ] Enable CloudTrail logging
- [ ] Add WAF rules

## 📊 Monitoring

Check service health:
```bash
sudo systemctl status workshop-backend.service
sudo systemctl status workshop-frontend.service

# View logs
sudo journalctl -u workshop-backend.service -f

# CPU/Memory usage
top
ps aux | grep node

# Network connections
ss -tlnp

# Disk usage
df -h
```

## 🔄 Maintenance

### Log Rotation
Services use systemd journal (auto-managed).

### Backup
Currently no automatic backup (in-memory data).

### Updates
```bash
# Update OS
sudo apt-get update
sudo apt-get upgrade -y

# Restart services
sudo systemctl restart workshop-backend.service
```