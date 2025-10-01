# CCPM Railway Deployment Guide

This guide walks you through deploying the CCPM (Claude Code Project Manager) orchestration system to Railway.

## 🚀 Quick Deploy

### Prerequisites
- GitHub account with the `klogins-hash/claude-code-ccpm` repository
- Railway account (free tier works)
- GitHub Personal Access Token (for CCPM GitHub integration)

### 1-Click Deploy to Railway

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/deploy?referralCode=YOUR_CODE)

Or follow the manual steps below:

## 📋 Manual Deployment Steps

### Step 1: Prepare Repository
Ensure your repository is up to date:
```bash
git add .
git commit -m "Prepare for Railway deployment"
git push origin main
```

### Step 2: Create Railway Project
1. Go to [Railway.app](https://railway.app)
2. Sign in with GitHub
3. Click "New Project"
4. Select "Deploy from GitHub repo"
5. Choose `klogins-hash/claude-code-ccpm`

### Step 3: Configure Environment Variables
In Railway dashboard, go to Variables tab and add:

**Required Variables:**
```
PORT=8080
PYTHONUNBUFFERED=1
NODE_ENV=production
```

**Optional Variables (for full functionality):**
```
GITHUB_TOKEN=your_github_personal_access_token
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com
```

### Step 4: Deploy
Railway will automatically:
1. Detect the Dockerfile
2. Build the container image
3. Deploy to a public URL
4. Set up health checks

## 🔧 Configuration Details

### Docker Configuration
The deployment uses:
- **Base Image**: Ubuntu 22.04
- **Runtime**: Python 3 + Flask + Gunicorn
- **Port**: 8080 (configurable via PORT env var)
- **Health Check**: `/health` endpoint
- **Process Manager**: Gunicorn with 2 workers

### Railway Configuration (`railway.toml`)
```toml
[build]
builder = "dockerfile"
dockerfilePath = "Dockerfile"

[deploy]
healthcheckPath = "/health"
healthcheckTimeout = 300
restartPolicyType = "on_failure"
restartPolicyMaxRetries = 3

[services]
source = "klogins-hash/claude-code-ccpm"

[services.variables]
PORT = "8080"
PYTHONUNBUFFERED = "1"
NODE_ENV = "production"
```

### Security Features
- Command execution limited to `/pm:` commands only
- Input sanitization and validation
- Secure environment variable handling
- Health check monitoring

## 🌐 Accessing Your Deployment

Once deployed, you'll get a Railway URL like:
```
https://your-app-name.railway.app
```

### Web Interface Features
- **Interactive Command Execution**: Run CCPM commands through web UI
- **Quick Commands**: Pre-configured buttons for common operations
- **Real-time Output**: See command results in real-time
- **Error Handling**: Clear error messages and status indicators

### Available Commands
```bash
# Help and initialization
/pm:help
/pm:init

# Project management
/pm:prd-new feature-name
/pm:epic-list
/pm:epic-start epic-name

# Agent orchestration
/pm:agent-orchestrate requirements-analysis epic-name
/pm:agent-orchestrate code-review
/pm:agent-orchestrate security-audit
```

## 🔍 Monitoring & Health Checks

### Health Check Endpoint
```
GET /health
```
Returns:
```json
{
  "status": "healthy",
  "service": "ccpm-web"
}
```

### Railway Monitoring
Railway provides built-in monitoring for:
- **CPU Usage**: Track resource utilization
- **Memory Usage**: Monitor memory consumption
- **Request Metrics**: HTTP request rates and response times
- **Logs**: Real-time application logs
- **Deployments**: Deployment history and status

### Log Access
View logs in Railway dashboard or via CLI:
```bash
railway logs
```

## 🛠️ Troubleshooting

### Common Issues

#### 1. Build Failures
**Symptom**: Deployment fails during build
**Solution**: Check build logs for missing dependencies or syntax errors
```bash
railway logs --deployment
```

#### 2. Health Check Failures
**Symptom**: Service shows as unhealthy
**Solution**: Verify the `/health` endpoint is responding
```bash
curl https://your-app.railway.app/health
```

#### 3. Command Execution Errors
**Symptom**: Commands fail in web interface
**Solution**: Check that commands start with `/pm:` and verify CCPM structure

#### 4. GitHub Integration Issues
**Symptom**: GitHub-related commands fail
**Solution**: Verify `GITHUB_TOKEN` environment variable is set correctly

### Debug Mode
Enable debug logging by adding environment variable:
```
CCPM_DEBUG=true
```

### Validation Script
Run the deployment validation script locally:
```bash
./validate-deployment.sh
```

## 🔄 Updates & Maintenance

### Automatic Deployments
Railway automatically deploys when you push to the `main` branch:
```bash
git add .
git commit -m "Update CCPM system"
git push origin main
```

### Manual Deployments
Trigger manual deployment in Railway dashboard:
1. Go to Deployments tab
2. Click "Deploy Latest Commit"

### Rollback
Rollback to previous deployment:
1. Go to Deployments tab
2. Find previous successful deployment
3. Click "Redeploy"

## 📊 Performance Optimization

### Resource Allocation
Railway free tier provides:
- **CPU**: Shared vCPU
- **Memory**: 512MB RAM
- **Storage**: 1GB disk
- **Bandwidth**: 100GB/month

### Scaling Options
For production use, consider upgrading to:
- **Pro Plan**: More CPU and memory
- **Custom Domains**: Use your own domain
- **Team Features**: Collaboration tools

### Optimization Tips
1. **Enable Caching**: Use Redis for session storage
2. **Optimize Images**: Minimize Docker image size
3. **Monitor Usage**: Track resource consumption
4. **Use CDN**: For static assets (if added)

## 🔐 Security Best Practices

### Environment Variables
- Store sensitive data in Railway environment variables
- Never commit secrets to repository
- Use strong GitHub personal access tokens
- Regularly rotate access tokens

### Network Security
- Railway provides HTTPS by default
- Use secure headers in Flask application
- Implement rate limiting for production use
- Monitor for suspicious activity

### Access Control
- Limit GitHub token permissions to minimum required
- Use read-only tokens when possible
- Implement user authentication for production use
- Regular security audits

## 📈 Monitoring & Analytics

### Built-in Metrics
Railway provides:
- Request count and response times
- Error rates and status codes
- Resource utilization graphs
- Deployment success rates

### Custom Monitoring
Add application-specific monitoring:
```python
# In web_interface.py
import logging
logging.basicConfig(level=logging.INFO)

# Log important events
logger.info(f"Command executed: {command}")
logger.error(f"Command failed: {error}")
```

### Alerting
Set up alerts in Railway dashboard for:
- High error rates
- Resource exhaustion
- Deployment failures
- Health check failures

## 🎯 Production Considerations

### For Production Use
Consider these enhancements:

1. **Authentication**: Add user authentication
2. **Rate Limiting**: Implement request rate limiting
3. **Logging**: Enhanced structured logging
4. **Monitoring**: Application performance monitoring
5. **Backup**: Regular data backups
6. **SSL**: Custom SSL certificates
7. **CDN**: Content delivery network for assets

### Scaling Strategy
1. **Horizontal Scaling**: Multiple Railway services
2. **Database**: Add persistent database for state
3. **Queue System**: Background job processing
4. **Load Balancing**: Distribute traffic across instances

## 📞 Support

### Getting Help
- **Railway Documentation**: [docs.railway.app](https://docs.railway.app)
- **Railway Discord**: Community support
- **GitHub Issues**: Report bugs and feature requests
- **CCPM Documentation**: See `ORCHESTRATION_README.md`

### Useful Commands
```bash
# Railway CLI commands
railway login
railway link
railway logs
railway status
railway deploy
railway open
```

---

## ✅ Deployment Checklist

Before deploying, ensure:

- [ ] Repository is up to date on GitHub
- [ ] All required files are present (Dockerfile, railway.toml, etc.)
- [ ] Environment variables are configured
- [ ] GitHub token has appropriate permissions
- [ ] Validation script passes
- [ ] Health check endpoint works
- [ ] Security considerations addressed

Your CCPM orchestration system is now ready for deployment! 🚀
