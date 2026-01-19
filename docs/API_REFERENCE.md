# Personal Profile API Documentation

Complete reference for the Personal Profile Backend API.

## Base URL

```
http://localhost:443
# or on EC2:
http://YOUR_EC2_PUBLIC_IP:443
```

## Endpoints

### Health Check

**GET** `/api/health`

Check if the backend is running.

**Response:**
```json
{
  "status": "ok",
  "message": "Personal Profile Backend is running on AWS EC2!",
  "timestamp": "2024-01-14T10:30:00.000Z"
}
```

---

### Get Profile

**GET** `/api/profile`

Retrieve the complete profile information.

**Response:**
```json
{
  "success": true,
  "data": {
    "name": "Your Name",
    "title": "Full Stack Developer",
    "bio": "Welcome to my AWS-hosted personal web profile!",
    "email": "your.email@example.com",
    "github": "https://github.com/yourprofile",
    "linkedin": "https://linkedin.com/in/yourprofile",
    "avatar": "👤",
    "likes": 5,
    "likedBy": ["Alice", "Bob", "Charlie"],
    "joinedDate": "2024-01-14T10:00:00.000Z",
    "updatedAt": "2024-01-14T11:00:00.000Z"
  }
}
```

---

### Update Profile

**PUT** `/api/profile`

Update profile information.

**Request Body:**
```json
{
  "name": "Jane Doe",
  "title": "Senior Developer",
  "bio": "Passionate about cloud computing",
  "email": "jane@example.com",
  "github": "https://github.com/janedoe",
  "linkedin": "https://linkedin.com/in/janedoe"
}
```

All fields are optional. Only include fields you want to update.

**Response:**
```json
{
  "success": true,
  "data": {
    "name": "Jane Doe",
    "title": "Senior Developer",
    "bio": "Passionate about cloud computing",
    "email": "jane@example.com",
    "github": "https://github.com/janedoe",
    "linkedin": "https://linkedin.com/in/janedoe",
    "avatar": "👤",
    "likes": 5,
    "likedBy": ["Alice", "Bob", "Charlie"],
    "joinedDate": "2024-01-14T10:00:00.000Z",
    "updatedAt": "2024-01-14T11:30:00.000Z"
  }
}
```

**Example with cURL:**
```bash
curl -X PUT http://localhost:443/api/profile \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Doe",
    "title": "Senior Developer",
    "bio": "Passionate about cloud computing"
  }'
```

---

### Like Profile

**POST** `/api/profile/like`

Like the profile (once per visitor).

**Request Body:**
```json
{
  "visitorName": "Alice"
}
```

`visitorName` is optional. If not provided, defaults to "Anonymous".

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "likes": 6,
    "message": "Alice liked your profile!"
  }
}
```

**Error Response - Already Liked (400):**
```json
{
  "success": false,
  "error": "You already liked this profile",
  "likes": 5
}
```

**Example with cURL:**
```bash
curl -X POST http://localhost:443/api/profile/like \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"Alice"}'
```

**Example with JavaScript:**
```javascript
fetch('http://localhost:443/api/profile/like', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ visitorName: 'Alice' })
})
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

---

### Unlike Profile

**POST** `/api/profile/unlike`

Unlike the profile (remove a like).

**Request Body:**
```json
{
  "visitorName": "Alice"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "data": {
    "likes": 4,
    "message": "Alice unliked your profile"
  }
}
```

**Error Response - Not Liked (400):**
```json
{
  "success": false,
  "error": "You have not liked this profile yet",
  "likes": 5
}
```

**Example with cURL:**
```bash
curl -X POST http://localhost:443/api/profile/unlike \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"Alice"}'
```

---

## Error Handling

All error responses include a `success: false` flag and an error message.

**Common Status Codes:**

| Code | Meaning |
|------|---------|
| 200 | Success |
| 400 | Bad Request (invalid JSON, already liked, etc.) |
| 404 | Not Found |
| 500 | Server Error |

**Example Error Response:**
```json
{
  "success": false,
  "error": "Invalid JSON"
}
```

---

## Data Model

### Profile Object

```javascript
{
  name: string,           // Profile name
  title: string,          // Job title or tagline
  bio: string,            // Short biography
  email: string,          // Email address
  github: string,         // GitHub URL
  linkedin: string,       // LinkedIn URL
  avatar: string,         // Avatar emoji (👤)
  likes: number,          // Total likes count
  likedBy: string[],      // Array of visitor names who liked
  joinedDate: ISO8601,    // When profile was created
  updatedAt: ISO8601      // Last update time
}
```

---

## Rate Limiting

Currently, there is **no rate limiting**. In production, implement:
- Limit likes per IP address
- Limit profile updates per time period
- Implement CORS restrictions

---

## CORS

By default, the API allows requests from:
- `http://localhost:3000`
- `http://localhost`
- Any origin that matches `ALLOWED_ORIGINS` environment variable

To change CORS settings, edit `backend/app.js`:

```javascript
const ALLOWED_ORIGINS = process.env.ALLOWED_ORIGINS || 'http://localhost:3000,http://localhost';
```

---

## Testing

### Using cURL

```bash
# Health check
curl http://localhost:443/api/health

# Get profile
curl http://localhost:443/api/profile

# Update profile
curl -X PUT http://localhost:443/api/profile \
  -H "Content-Type: application/json" \
  -d '{"name":"New Name"}'

# Like profile
curl -X POST http://localhost:443/api/profile/like \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"Test User"}'

# Unlike profile
curl -X POST http://localhost:443/api/profile/unlike \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"Test User"}'
```

### Using Postman

1. Import the API endpoints
2. Set up variables for `base_url`
3. Create requests for each endpoint
4. Test different scenarios

---

## Limitations

- **In-memory storage**: All data is lost on restart
- **No authentication**: Anyone can update the profile
- **No persistence**: No database integration
- **Single instance**: No distributed caching

To address these, add:
- Database (PostgreSQL, MongoDB, etc.)
- Authentication (JWT, OAuth)
- API rate limiting
- Load balancing

---

## Examples

### Complete Profile Update Workflow

```bash
# 1. Get current profile
curl http://localhost:443/api/profile

# 2. Update profile
curl -X PUT http://localhost:443/api/profile \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Developer",
    "title": "Full Stack Engineer",
    "bio": "Building amazing things with AWS",
    "email": "jane@example.com",
    "github": "https://github.com/janedeveloper",
    "linkedin": "https://linkedin.com/in/janedeveloper"
  }'

# 3. Get updated profile
curl http://localhost:443/api/profile

# 4. Like the profile
curl -X POST http://localhost:443/api/profile/like \
  -H "Content-Type: application/json" \
  -d '{"visitorName":"John"}'

# 5. Verify like was added
curl http://localhost:443/api/profile
```

---

## Support

For issues or questions:
1. Check the logs: `sudo journalctl -u workshop-backend.service -f`
2. Verify backend is running: `sudo systemctl status workshop-backend.service`
3. Test connectivity: `curl http://localhost:443/api/health`

---

**Last Updated**: January 14, 2024
