#!/bin/bash

# Netlify Deployment Troubleshooting Script
# This script helps diagnose common deployment issues

set -e

echo "=================================================="
echo "Netlify Deployment Troubleshooter"
echo "=================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}!${NC} $1"
}

# Check Node version
echo "Checking Node version..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js installed: $NODE_VERSION"
    
    # Check if version matches netlify.toml
    if [[ $NODE_VERSION == v18* ]]; then
        print_success "Node version matches netlify.toml (v18)"
    else
        print_warning "Node version doesn't match netlify.toml requirement (v18)"
        echo "  Current: $NODE_VERSION, Expected: v18.x"
    fi
else
    print_error "Node.js not installed"
    exit 1
fi

echo ""

# Check npm version
echo "Checking npm version..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm installed: $NPM_VERSION"
else
    print_error "npm not installed"
    exit 1
fi

echo ""

# Check if package.json exists
echo "Checking project files..."
if [ -f "package.json" ]; then
    print_success "package.json found"
else
    print_error "package.json not found"
    exit 1
fi

if [ -f "netlify.toml" ]; then
    print_success "netlify.toml found"
else
    print_warning "netlify.toml not found (optional but recommended)"
fi

echo ""

# Check package.json for build script
echo "Checking build configuration..."
if grep -q '"build"' package.json; then
    BUILD_SCRIPT=$(grep '"build"' package.json | head -1)
    print_success "Build script found: $BUILD_SCRIPT"
else
    print_error "No 'build' script found in package.json"
    exit 1
fi

echo ""

# Check if node_modules exists
echo "Checking dependencies..."
if [ -d "node_modules" ]; then
    print_success "node_modules directory exists"
else
    print_warning "node_modules directory not found - running npm install..."
    npm install
    print_success "Dependencies installed"
fi

echo ""

# Try to build the project
echo "Testing build process..."
echo "Running: npm run build"
echo "----------------------------------------"

if npm run build; then
    echo "----------------------------------------"
    print_success "Build completed successfully!"
else
    echo "----------------------------------------"
    print_error "Build failed! Check errors above."
    exit 1
fi

echo ""

# Check if dist folder was created
echo "Checking build output..."
if [ -d "dist" ]; then
    print_success "dist/ directory created"
    
    # Check for index.html
    if [ -f "dist/index.html" ]; then
        print_success "dist/index.html exists"
        
        # Check file size
        SIZE=$(du -h dist/index.html | cut -f1)
        echo "  File size: $SIZE"
        
        # Check if it contains the root div
        if grep -q 'id="root"' dist/index.html; then
            print_success "Root element found in HTML"
        else
            print_error "Root element not found in HTML"
        fi
        
        # Check for script tags
        if grep -q '<script' dist/index.html; then
            print_success "Script tags found in HTML"
            SCRIPT_COUNT=$(grep -c '<script' dist/index.html)
            echo "  Script tags: $SCRIPT_COUNT"
        else
            print_error "No script tags found in HTML"
        fi
    else
        print_error "dist/index.html not found"
    fi
    
    # Check for assets folder
    if [ -d "dist/assets" ]; then
        print_success "dist/assets/ directory exists"
        
        # Count JavaScript files
        JS_COUNT=$(find dist/assets -name "*.js" | wc -l)
        CSS_COUNT=$(find dist/assets -name "*.css" | wc -l)
        
        echo "  JavaScript files: $JS_COUNT"
        echo "  CSS files: $CSS_COUNT"
        
        if [ $JS_COUNT -gt 0 ]; then
            print_success "JavaScript bundles generated"
        else
            print_error "No JavaScript bundles found"
        fi
        
        if [ $CSS_COUNT -gt 0 ]; then
            print_success "CSS bundles generated"
        else
            print_error "No CSS bundles found"
        fi
    else
        print_error "dist/assets/ directory not found"
    fi
else
    print_error "dist/ directory not created"
    exit 1
fi

echo ""

# Check total dist size
echo "Checking build size..."
DIST_SIZE=$(du -sh dist | cut -f1)
echo "Total dist/ size: $DIST_SIZE"

if command -v find &> /dev/null; then
    echo ""
    echo "Largest files in dist/:"
    find dist -type f -exec du -h {} + | sort -rh | head -10
fi

echo ""

# Summary
echo "=================================================="
echo "Build Verification Summary"
echo "=================================================="
print_success "Local build completed successfully!"
echo ""
echo "Next steps for Netlify deployment:"
echo "1. Go to Netlify Dashboard → Your Site → Deploys"
echo "2. Click 'Trigger deploy' → 'Clear cache and deploy site'"
echo "3. Wait for build to complete"
echo "4. Check build logs for any errors"
echo "5. Test site at both *.netlify.app and dobeu.net"
echo "6. Hard refresh browser (Ctrl+Shift+R)"
echo ""
echo "If site still doesn't load:"
echo "- Check browser console (F12) for JavaScript errors"
echo "- Check Network tab (F12) for failed asset loads"
echo "- Verify MONGODB_URI environment variable is set"
echo "- See NETLIFY_FIX_GUIDE.md for detailed troubleshooting"
echo ""
print_success "Troubleshooting complete!"
