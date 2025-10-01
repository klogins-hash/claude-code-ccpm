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
