# Deployment Guide - Different Linux Distributions

This workshop includes deployment scripts for different AWS EC2 Linux distributions.

## 📋 Available Scripts

| Script | OS | Best For |
|--------|----|----|
| `deploy.sh` | Ubuntu 20.04 LTS | Standard AWS AMI, Canonical-maintained |
| `deploy-amazon-linux.sh` | Amazon Linux 2 / 2023 | AWS-optimized, minimal |

## 🐧 Which Should I Choose?

### Ubuntu (deploy.sh)
✅ **Use if:**
- You're using Ubuntu 20.04 LTS AMI
- You prefer broader software support
- You want maximum package compatibility

❌ **Don't use if:**
- Your AMI is Amazon Linux based
- You want minimal OS footprint

### Amazon Linux (deploy-amazon-linux.sh)
✅ **Use if:**
- You're using Amazon Linux 2 or Amazon Linux 2023
- You want lightweight, AWS-optimized OS
- You prefer yum/dnf package manager

❌ **Don't use if:**
- Your AMI is Ubuntu-based
- You need specific Ubuntu-only packages

## 🚀 Deployment Steps

### For Ubuntu 20.04 LTS
```bash
chmod +x deploy.sh
./deploy.sh
```

### For Amazon Linux 2 / 2023
```bash
chmod +x deploy-amazon-linux.sh
./deploy-amazon-linux.sh
```

## 🔄 Key Differences

### Package Manager
| Feature | Ubuntu | Amazon Linux |
|---------|--------|--------------|
| Package Manager | `apt-get` | `yum` (AL2) / `dnf` (AL2023) |
| Update Command | `apt-get update` | `yum update` |
| Install Command | `apt-get install` | `yum install` |

### Default User
| OS | Default User |
|----|---|
| Ubuntu | `ubuntu` |
| Amazon Linux | `ec2-user` |

### Node.js Installation
| OS | Method |
|----|--------|
| Ubuntu | NodeSource repository (setup script) |
| Amazon Linux | Direct yum/dnf install |

## 📍 How to Choose Your AMI

### In AWS Console:
1. Go to **EC2 → Launch Instance**
2. Click **Browse more AMIs**
3. Search for:
   - **"ubuntu/images/hvm-ssd/ubuntu-focal-20.04"** (Ubuntu)
   - **"amzn2-ami-hvm"** or **"al2023-ami"** (Amazon Linux)

### Or check your current instance:
```bash
cat /etc/os-release
```

## 🆘 Troubleshooting

### Wrong Deployment Script?
If you ran the wrong script, the error will be in package installation:
```bash
# Ubuntu script on Amazon Linux:
E: Could not open lock file /var/lib/apt/lists/lock

# Amazon Linux script on Ubuntu:
E: Could not find a matching package
```

### Solution:
1. Note the error
2. Run the correct script for your distribution
3. Services should start correctly

### Check Your Distribution:
```bash
# Find OS name
grep "^NAME=" /etc/os-release

# Output will be:
# Ubuntu: NAME="Ubuntu"
# Amazon Linux 2: NAME="Amazon Linux"
# Amazon Linux 2023: NAME="Amazon Linux"
```

## 📊 Performance Comparison

| Metric | Ubuntu | Amazon Linux |
|--------|--------|--------------|
| Boot Time | ~45-60s | ~30-45s |
| Image Size | ~1GB | ~0.5GB |
| Package Availability | Very High | High |
| AWS Integration | Good | Excellent |
| Node.js Versions | Latest | Latest |

## 🔐 Security Notes

Both scripts:
- ✅ Update system packages
- ✅ Install latest Node.js
- ✅ Use systemd service hardening
- ✅ Set proper file permissions

For production, additionally:
- [ ] Use VPC with security groups
- [ ] Enable CloudTrail logging
- [ ] Use IAM roles (not credentials)
- [ ] Implement WAF rules
- [ ] Enable VPC Flow Logs

## 💡 Tips

### Multi-Distribution Setup
If supporting both OSes:
```bash
# Auto-detect and run correct script
if grep -q "Ubuntu" /etc/os-release; then
  ./deploy.sh
elif grep -q "Amazon Linux" /etc/os-release; then
  ./deploy-amazon-linux.sh
fi
```

### Custom AMIs
To add support for other distributions (CentOS, RHEL, etc.):
1. Check package manager (`dnf`, `zypper`, etc.)
2. Find equivalent packages
3. Create new deployment script
4. Test thoroughly

## 📚 Further Reading

- [Ubuntu AMI Guide](https://cloud-images.ubuntu.com/locator/)
- [Amazon Linux 2 Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-2-dev-updates.html)
- [Amazon Linux 2023 Guide](https://docs.aws.amazon.com/linux/al2023/ug/what-is-amazon-linux.html)
- [Node.js on AWS](https://nodejs.org/en/docs/guides/nodejs-on-aws-ec2-instance/)

---

**Need help?** Check the logs:
```bash
sudo journalctl -u workshop-backend.service -n 50
sudo journalctl -u workshop-frontend.service -n 50
```
