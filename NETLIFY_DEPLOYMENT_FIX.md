# Netlify Deployment Fix - Dobeu Tech Solutions

## Problem Identified

The website at https://dobeutechsolutions.netlify.app is showing only a background color because:

**Root Cause:** Missing Supabase environment variables in Netlify deployment

Console Error:
```
Error: Missing Supabase environment variables
```

The app throws this error in `src/lib/supabase.ts` when `VITE_SUPABASE_URL` or `VITE_SUPABASE_ANON_KEY` are not set, causing the entire React app to crash during initialization.

## Solution

### Step 1: Get Supabase Credentials

From your Supabase dashboard (https://supabase.com/dashboard):
1. Select your project
2. Go to **Project Settings** → **API**
3. Copy the **Project URL** (should be: `https://qmwefqnbeipmbydhfcfj.supabase.co`)
4. Copy the **anon/public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

### Step 2: Configure Environment Variables in Netlify

#### Option A: Via Netlify CLI (Recommended)

```bash
# Set your Netlify auth token
$env:NETLIFY_AUTH_TOKEN="nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce"

# Create or link to the site
netlify init

# Set environment variables
netlify env:set VITE_SUPABASE_URL "https://qmwefqnbeipmbydhfcfj.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "YOUR_ACTUAL_ANON_KEY_HERE"

# Deploy
netlify deploy --prod
```

#### Option B: Via Netlify Dashboard

1. Go to https://app.netlify.com/
2. Select your site (or create a new one)
3. Go to **Site settings** → **Environment variables**
4. Click **Add a variable**
5. Add:
   - Key: `VITE_SUPABASE_URL`
   - Value: `https://qmwefqnbeipmbydhfcfj.supabase.co`
   - Scopes: All scopes (or at least Production)
6. Add:
   - Key: `VITE_SUPABASE_ANON_KEY`
   - Value: Your Supabase anon key
   - Scopes: All scopes (or at least Production)
7. Trigger a new deployment: **Deploys** → **Trigger deploy** → **Clear cache and deploy site**

### Step 3: Set Up Custom Domain (dobeu.net)

#### Via Netlify Dashboard:

1. Go to **Site settings** → **Domain management**
2. Click **Add a domain**
3. Enter `dobeu.net`
4. Configure DNS:
   - If your domain is registered elsewhere:
     - Add A record: `@` → `75.2.60.5` (Netlify's load balancer)
     - Or add CNAME record: `@` → `apex-loadbalancer.netlify.com`
   - If using Netlify DNS:
     - Netlify will auto-configure

5. Also add www subdomain:
   - Add CNAME: `www` → `dobeutechsolutions.netlify.app` (or your site URL)

#### Via Netlify CLI:

```bash
netlify domains:add dobeu.net
netlify domains:add www.dobeu.net
```

### Step 4: Verify Deployment

After environment variables are set and the site redeploys:

1. Check https://dobeutechsolutions.netlify.app (should now work)
2. Check https://dobeu.net (after DNS propagates, typically 5-15 minutes)
3. Open browser console - should see no errors
4. Test the contact form to verify Supabase connection

## Quick Fix Commands

```bash
# If you have the Supabase anon key ready, run these:
$env:NETLIFY_AUTH_TOKEN="nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce"

# Build the project
npm install
npm run build

# Deploy to Netlify
netlify deploy --prod --dir=dist

# Set environment variables (replace with actual key)
netlify env:set VITE_SUPABASE_URL "https://qmwefqnbeipmbydhfcfj.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# Redeploy to pick up the environment variables
netlify deploy --prod --dir=dist

# Add custom domain
netlify domains:add dobeu.net
```

## Alternative: Create New Site from Scratch

If the existing site is in a different account or you want to start fresh:

```bash
# Initialize new Netlify site
netlify init

# Follow prompts:
# - Create & configure a new site: Yes
# - Team: Select your team
# - Site name: dobeu-net (or preferred name)
# - Build command: npm run build
# - Publish directory: dist

# Set environment variables
netlify env:set VITE_SUPABASE_URL "https://qmwefqnbeipmbydhfcfj.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "YOUR_KEY_HERE"

# Deploy
netlify deploy --prod
```

## Verification Checklist

After deployment:

- [ ] Site loads at Netlify URL (no blank page)
- [ ] Browser console shows no errors
- [ ] Dark mode toggle works
- [ ] Navigation scrolls to sections
- [ ] Contact form can be opened
- [ ] Form submission works (test with Supabase)
- [ ] Site loads at https://dobeu.net
- [ ] SSL certificate is valid for dobeu.net
- [ ] www.dobeu.net redirects to dobeu.net (or vice versa)

## Current Git Branch

You're currently on the `dev` branch with an initial commit. When ready to deploy to production:

```bash
# Merge dev to main
git checkout main
git merge dev
git push origin main

# Or deploy from dev branch
netlify deploy --prod --branch=dev
```

