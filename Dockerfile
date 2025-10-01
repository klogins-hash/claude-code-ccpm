# Multi-stage build for CCPM deployment
FROM ubuntu:22.04 as base

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    bash \
    git \
    curl \
    wget \
    jq \
    python3 \
    python3-pip \
    nodejs \
    npm \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install gh -y

# Create app directory
WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt .

# Install Python dependencies for web interface
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy CCPM files
COPY . .

# Make scripts executable
RUN find . -name "*.sh" -exec chmod +x {} \;

# Web interface is now copied as a separate file

# Make the web interface executable
RUN chmod +x /app/web_interface.py

# Expose port
EXPOSE 8080

# Set up entrypoint
RUN cat > /app/entrypoint.sh << 'EOF'
#!/bin/bash
set -e

# Initialize git config if not set
git config --global user.name "${GIT_USER_NAME:-CCPM User}"
git config --global user.email "${GIT_USER_EMAIL:-ccpm@example.com}"

# Set up GitHub CLI authentication if token is provided
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token
fi

# Start the web interface with gunicorn for production
exec gunicorn --bind 0.0.0.0:${PORT:-8080} --workers 2 --timeout 120 web_interface:app
EOF

RUN chmod +x /app/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/app/entrypoint.sh"]
