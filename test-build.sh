#!/bin/bash

# Test script to validate Docker build readiness
echo "🔍 Testing Docker build readiness..."

# Check if all required files exist
required_files=(
    "Dockerfile"
    "requirements.txt"
    "web_interface.py"
    "entrypoint.sh"
    ".dockerignore"
)

echo "📁 Checking required files..."
missing_files=0
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file"
    else
        echo "❌ $file (missing)"
        ((missing_files++))
    fi
done

# Check file permissions
echo ""
echo "🔐 Checking file permissions..."
if [ -x "entrypoint.sh" ]; then
    echo "✅ entrypoint.sh is executable"
else
    echo "❌ entrypoint.sh is not executable"
    ((missing_files++))
fi

if [ -r "web_interface.py" ]; then
    echo "✅ web_interface.py is readable"
else
    echo "❌ web_interface.py is not readable"
    ((missing_files++))
fi

# Test Python syntax
echo ""
echo "🐍 Testing Python syntax..."
if python3 -m py_compile web_interface.py 2>/dev/null; then
    echo "✅ web_interface.py syntax is valid"
else
    echo "❌ web_interface.py has syntax errors"
    ((missing_files++))
fi

# Test bash syntax
echo ""
echo "📜 Testing bash syntax..."
if bash -n entrypoint.sh 2>/dev/null; then
    echo "✅ entrypoint.sh syntax is valid"
else
    echo "❌ entrypoint.sh has syntax errors"
    ((missing_files++))
fi

# Check Dockerfile structure
echo ""
echo "🐳 Checking Dockerfile structure..."
if grep -q "FROM ubuntu:22.04" Dockerfile; then
    echo "✅ Base image specified"
else
    echo "❌ Base image not found"
    ((missing_files++))
fi

if grep -q "COPY requirements.txt" Dockerfile; then
    echo "✅ Requirements copying configured"
else
    echo "❌ Requirements copying not configured"
    ((missing_files++))
fi

if grep -q "pip3 install" Dockerfile; then
    echo "✅ Python package installation configured"
else
    echo "❌ Python package installation not configured"
    ((missing_files++))
fi

if grep -q "ENTRYPOINT" Dockerfile; then
    echo "✅ Entrypoint configured"
else
    echo "❌ Entrypoint not configured"
    ((missing_files++))
fi

# Check for problematic heredocs
echo ""
echo "⚠️  Checking for problematic patterns..."
if grep -q "<<" Dockerfile; then
    echo "❌ Found heredoc in Dockerfile (potential syntax issue)"
    echo "   Heredocs can cause build failures - use separate files instead"
    ((missing_files++))
else
    echo "✅ No heredocs found in Dockerfile"
fi

# Final assessment
echo ""
echo "📊 Build readiness assessment:"
if [ $missing_files -eq 0 ]; then
    echo "✅ READY FOR DEPLOYMENT!"
    echo "   All files present and valid"
    echo "   No syntax errors detected"
    echo "   Dockerfile structure is correct"
    echo ""
    echo "🚀 You can now deploy to Railway!"
    exit 0
else
    echo "❌ ISSUES FOUND: $missing_files problems detected"
    echo "   Please fix the issues above before deploying"
    exit 1
fi
