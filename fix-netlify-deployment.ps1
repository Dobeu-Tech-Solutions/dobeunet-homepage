# Dobeu Net - Netlify Deployment Fix Script
# This script will configure environment variables and deploy to Netlify

param(
    [Parameter(Mandatory=$true)]
    [string]$SupabaseAnonKey
)

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Dobeu Net - Netlify Deployment Fix" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Set Netlify auth token
$env:NETLIFY_AUTH_TOKEN = "nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce"

# Supabase configuration
$SUPABASE_URL = "https://qmwefqnbeipmbydhfcfj.supabase.co"

Write-Host "Step 1: Installing dependencies..." -ForegroundColor Yellow
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Building the project..." -ForegroundColor Yellow

# Temporarily set env vars for build
$env:VITE_SUPABASE_URL = $SUPABASE_URL
$env:VITE_SUPABASE_ANON_KEY = $SupabaseAnonKey

npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 3: Initializing Netlify site..." -ForegroundColor Yellow

# Check if already linked
if (!(Test-Path ".netlify")) {
    Write-Host "Creating new Netlify site..." -ForegroundColor Gray
    
    # Create a netlify.toml configuration
    $netlifyConfig = @"
[build]
  publish = "dist"
  command = "npm run build"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
"@
    
    Set-Content -Path "netlify.toml" -Value $netlifyConfig
    
    # Initialize new site
    netlify init --manual
}

Write-Host ""
Write-Host "Step 4: Setting environment variables..." -ForegroundColor Yellow

# Set environment variables in Netlify
netlify env:set VITE_SUPABASE_URL $SUPABASE_URL
netlify env:set VITE_SUPABASE_ANON_KEY $SupabaseAnonKey

Write-Host ""
Write-Host "Step 5: Deploying to production..." -ForegroundColor Yellow

netlify deploy --prod --dir=dist

Write-Host ""
Write-Host "Step 6: Configuring custom domain..." -ForegroundColor Yellow

# Add custom domain
netlify domains:add dobeu.net

Write-Host ""
Write-Host "====================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your site should now be live at:" -ForegroundColor White
Write-Host "  - Netlify URL: Check output above" -ForegroundColor Gray
Write-Host "  - Custom domain: https://dobeu.net (after DNS propagates)" -ForegroundColor Gray
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update your DNS records to point to Netlify" -ForegroundColor White
Write-Host "   - Add A record: @ -> 75.2.60.5" -ForegroundColor Gray
Write-Host "   - Or CNAME: @ -> apex-loadbalancer.netlify.com" -ForegroundColor Gray
Write-Host "   - Add CNAME: www -> your-site.netlify.app" -ForegroundColor Gray
Write-Host "2. Wait 5-15 minutes for DNS to propagate" -ForegroundColor White
Write-Host "3. Verify the site loads at https://dobeu.net" -ForegroundColor White
Write-Host ""

