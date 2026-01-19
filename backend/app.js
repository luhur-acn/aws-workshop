const http = require('http');
const url = require('url');

// In-memory database - Personal Profile
let profile = {
  name: 'Your Name',
  title: 'Full Stack Developer',
  bio: 'Welcome to my AWS-hosted personal web profile!',
  email: 'your.email@example.com',
  github: 'https://github.com/yourprofile',
  linkedin: 'https://linkedin.com/in/yourprofile',
  avatar: '👤',
  likes: 0,
  likedBy: [],
  joinedDate: new Date().toISOString(),
};

const PORT = process.env.PORT || 443;

// CORS helper - Allow requests from any origin (for workshop purposes)
// In production, restrict to specific origins
function setCorsHeaders(res, origin) {
  if (origin) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  } else {
    res.setHeader('Access-Control-Allow-Origin', '*');
  }
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  res.setHeader('Access-Control-Max-Age', '3600');
}

const server = http.createServer((req, res) => {
  const origin = req.headers.origin || '*';
  setCorsHeaders(res, origin);

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  // Health check
  if (pathname === '/api/health' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      status: 'ok',
      message: 'Personal Profile Backend is running on AWS EC2!',
      timestamp: new Date(),
    }));
    return;
  }

  // Get profile
  if (pathname === '/api/profile' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      success: true,
      data: profile,
    }));
    return;
  }

  // Update profile
  if (pathname === '/api/profile' && method === 'PUT') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const updates = JSON.parse(body);
        if (updates.name !== undefined) profile.name = updates.name;
        if (updates.title !== undefined) profile.title = updates.title;
        if (updates.bio !== undefined) profile.bio = updates.bio;
        if (updates.email !== undefined) profile.email = updates.email;
        if (updates.github !== undefined) profile.github = updates.github;
        if (updates.linkedin !== undefined) profile.linkedin = updates.linkedin;
        profile.updatedAt = new Date().toISOString();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: true, data: profile }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'Invalid JSON' }));
      }
    });
    return;
  }

  // Like profile
  if (pathname === '/api/profile/like' && method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { visitorName } = JSON.parse(body);
        const name = visitorName || 'Anonymous';
        
        // Check if already liked
        if (profile.likedBy.includes(name)) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ 
            success: false, 
            error: 'You already liked this profile',
            likes: profile.likes 
          }));
          return;
        }
        
        profile.likes++;
        profile.likedBy.push(name);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
          success: true, 
          data: {
            likes: profile.likes,
            message: `${name} liked your profile!`
          }
        }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'Invalid JSON' }));
      }
    });
    return;
  }

  // Unlike profile
  if (pathname === '/api/profile/unlike' && method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        const { visitorName } = JSON.parse(body);
        const name = visitorName || 'Anonymous';
        
        const index = profile.likedBy.indexOf(name);
        if (index === -1) {
          res.writeHead(400, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ 
            success: false, 
            error: 'You have not liked this profile yet',
            likes: profile.likes 
          }));
          return;
        }
        
        profile.likes--;
        profile.likedBy.splice(index, 1);
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ 
          success: true, 
          data: {
            likes: profile.likes,
            message: `${name} unliked your profile`
          }
        }));
      } catch (err) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ success: false, error: 'Invalid JSON' }));
      }
    });
    return;
  }

  // 404
  res.writeHead(404, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ success: false, error: 'Endpoint not found' }));
});

server.listen(PORT, () => {
  console.log(`✓ Profile Backend running on port ${PORT}`);
  console.log(`✓ Health check: http://localhost:${PORT}/api/health`);
  console.log(`✓ Get profile: http://localhost:${PORT}/api/profile`);
});
