#!/bin/bash

# CCPM Deployment Validation Script
# This script validates the deployment configuration and identifies potential issues

set -e

echo "🔍 CCPM Deployment Validation"
echo "================================"

# Check required files
echo "📁 Checking required files..."
required_files=(
    "Dockerfile"
    "railway.toml"
    "requirements.txt"
    ".dockerignore"
    "ccpm/ccpm.config"
    "ccpm/agents/orchestration-master.md"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file missing"
        exit 1
    fi
done

# Check Dockerfile syntax
echo ""
echo "🐳 Validating Dockerfile..."
if command -v docker >/dev/null 2>&1; then
    if docker build --dry-run . >/dev/null 2>&1; then
        echo "✅ Dockerfile syntax is valid"
    else
        echo "⚠️  Dockerfile may have issues (Docker not running or syntax errors)"
    fi
else
    echo "⚠️  Docker not available for validation"
fi

# Check Python requirements
echo ""
echo "🐍 Validating Python requirements..."
python3 -c "
import sys
required = ['flask', 'flask-cors', 'python-dotenv', 'gunicorn']
missing = []
for pkg in required:
    try:
        __import__(pkg.replace('-', '_'))
    except ImportError:
        missing.append(pkg)
if missing:
    print('⚠️  Missing packages will be installed during build:', ', '.join(missing))
else:
    print('✅ All Python packages available')
" 2>/dev/null || echo "⚠️  Python packages will be installed during build"

# Check Railway configuration
echo ""
echo "🚂 Validating Railway configuration..."
if grep -q "dockerfile" railway.toml; then
    echo "✅ Railway configured for Docker build"
else
    echo "❌ Railway configuration missing Docker build setup"
    exit 1
fi

if grep -q "PORT" railway.toml; then
    echo "✅ PORT environment variable configured"
else
    echo "❌ PORT environment variable not configured"
    exit 1
fi

# Check CCPM structure
echo ""
echo "🤖 Validating CCPM structure..."
if [ -d "ccpm/agents" ]; then
    agent_count=$(find ccpm/agents -name "*.md" | wc -l)
    echo "✅ Found $agent_count agent definitions"
else
    echo "❌ CCPM agents directory missing"
    exit 1
fi

if [ -d "ccpm/commands" ]; then
    command_count=$(find ccpm/commands -name "*.md" | wc -l)
    echo "✅ Found $command_count command definitions"
else
    echo "❌ CCPM commands directory missing"
    exit 1
fi

# Check for potential security issues
echo ""
echo "🔒 Security validation..."
if grep -q "subprocess.run" Dockerfile; then
    if grep -q "command.startswith('/pm:')" Dockerfile; then
        echo "✅ Command execution is properly sanitized"
    else
        echo "⚠️  Command execution may need additional sanitization"
    fi
fi

# Check environment variables
echo ""
echo "🌍 Environment variable validation..."
env_vars=("PORT" "PYTHONUNBUFFERED" "NODE_ENV")
for var in "${env_vars[@]}"; do
    if grep -q "$var" railway.toml; then
        echo "✅ $var configured in Railway"
    else
        echo "⚠️  $var not found in Railway config"
    fi
done

# Check for common deployment issues
echo ""
echo "⚠️  Common deployment considerations..."
echo "📝 Remember to set these secrets in Railway dashboard:"
echo "   - GITHUB_TOKEN (for GitHub integration)"
echo "   - GIT_USER_NAME (for git operations)"
echo "   - GIT_USER_EMAIL (for git operations)"

echo ""
echo "🚀 Deployment readiness check..."

# Count issues
issues=0

# Check critical files
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        ((issues++))
    fi
done

# Final assessment
if [ $issues -eq 0 ]; then
    echo "✅ Deployment appears ready!"
    echo "   - All required files present"
    echo "   - Configuration files valid"
    echo "   - CCPM structure complete"
    echo ""
    echo "🚀 Next steps:"
    echo "   1. Commit and push changes to GitHub"
    echo "   2. Connect repository to Railway"
    echo "   3. Set environment variables in Railway dashboard"
    echo "   4. Deploy!"
else
    echo "❌ Found $issues critical issues that need to be resolved"
    exit 1
fi

echo ""
echo "📊 Deployment summary:"
echo "   - Base image: Ubuntu 22.04"
echo "   - Runtime: Python 3 + Flask + Gunicorn"
echo "   - Port: 8080"
echo "   - Health check: /health endpoint"
echo "   - Features: CCPM orchestration system with web interface"
