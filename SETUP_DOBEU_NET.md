# Complete Setup Guide: Deploying Dobeu.net

## 🔍 Problem Diagnosis

**Current Issue:** Website at https://dobeutechsolutions.netlify.app shows only background color

**Root Cause:** Missing environment variables in Netlify deployment

Console Error:
```
Error: Missing Supabase environment variables
```

The React application crashes on initialization because `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY` are not configured.

---

## ✅ Solution Overview

You have two options:

### Option A: Fix Existing Site (If you have access to the Netlify account)
### Option B: Create New Site (Recommended - Fresh start)

---

## 📋 Prerequisites

Before starting, you need:

1. **Supabase Anon Key** (Required)
   - Go to: https://supabase.com/dashboard
   - Select project: `qmwefqnbeipmbydhfcfj`
   - Navigate to: **Project Settings** → **API**
   - Copy the **anon/public** key (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

2. **Netlify Access**
   - You have PAT token: `nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce`
   - Netlify account: jswilliamstu@outlook.com

3. **Domain Access**
   - Access to DNS settings for `dobeu.net`

---

## 🚀 Option A: Fix Existing Site via Netlify Dashboard

### Step 1: Access Netlify Dashboard

1. Go to https://app.netlify.com/
2. Log in with your account (jswilliamstu@outlook.com)
3. Find the site "dobeutechsolutions" (or the site serving dobeutechsolutions.netlify.app)

**Important:** The site might be under a different team/account. Check all teams in the dropdown at the top.

### Step 2: Set Environment Variables

1. Click on your site
2. Go to **Site settings** (in the top menu)
3. In the left sidebar, click **Environment variables** (under "Build & deploy" section)
4. Click **Add a variable** or **Add environment variables**
5. Add the following TWO variables:

**Variable 1:**
- **Key:** `VITE_SUPABASE_URL`
- **Value:** `https://qmwefqnbeipmbydhfcfj.supabase.co`
- **Scopes:** Select all (Production, Deploy Previews, Branch deploys) or at minimum Production

**Variable 2:**
- **Key:** `VITE_SUPABASE_ANON_KEY`
- **Value:** `<YOUR_SUPABASE_ANON_KEY>` (paste the key you got from Supabase)
- **Scopes:** Select all (Production, Deploy Previews, Branch deploys) or at minimum Production

6. Click **Create variable** or **Save**

### Step 3: Trigger Redeploy

1. Go to **Deploys** tab (top menu)
2. Click **Trigger deploy** button (top right)
3. Select **Clear cache and deploy site**
4. Wait for deployment to complete (usually 1-3 minutes)

### Step 4: Verify Fix

1. Open https://dobeutechsolutions.netlify.app
2. The site should now load completely (not just background)
3. Open browser console (F12) - should see no errors
4. Test navigation and dark mode toggle

### Step 5: Add Custom Domain

1. In Netlify dashboard, go to **Domain management** (under Site settings)
2. Click **Add a domain**
3. Enter: `dobeu.net`
4. Click **Verify** or **Add domain**
5. Follow DNS instructions provided by Netlify

Typical DNS setup:
```
Type: A
Name: @
Value: 75.2.60.5

Type: CNAME  
Name: www
Value: dobeutechsolutions.netlify.app
```

6. Wait 5-30 minutes for DNS to propagate
7. Access https://dobeu.net

---

## 🆕 Option B: Create New Site (Recommended)

If you can't find the existing site or want a fresh start:

### Step 1: Prepare Environment Variables

Create a file `.env.local` in your project root (for local testing):

```bash
VITE_SUPABASE_URL=https://qmwefqnbeipmbydhfcfj.supabase.co
VITE_SUPABASE_ANON_KEY=<YOUR_SUPABASE_ANON_KEY>
```

**Note:** This file is git-ignored and won't be committed.

### Step 2: Test Locally

```powershell
# Install dependencies
npm install

# Test build
npm run build

# Preview the build
npm run preview
```

Open the preview URL (usually http://localhost:4173) and verify everything works.

### Step 3: Deploy via CLI

```powershell
# Set Netlify auth token
$env:NETLIFY_AUTH_TOKEN = "nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce"

# Initialize new Netlify site
netlify init

# Answer prompts:
# "Create & configure a new site" → Yes
# "Team" → wtfisai's team (or your team)
# "Site name" → dobeu-net (or leave blank for auto-generated)
# "Build command" → npm run build
# "Directory to deploy" → dist

# The site will be created and linked
```

### Step 4: Set Environment Variables

```powershell
# Still with NETLIFY_AUTH_TOKEN set from previous step
netlify env:set VITE_SUPABASE_URL "https://qmwefqnbeipmbydhfcfj.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "YOUR_ACTUAL_KEY_HERE"
```

Replace `YOUR_ACTUAL_KEY_HERE` with your Supabase anon key.

### Step 5: Deploy to Production

```powershell
netlify deploy --prod
```

You'll get a URL like: https://dobeu-net.netlify.app (or your chosen name)

### Step 6: Add Custom Domain

```powershell
netlify domains:add dobeu.net
```

Follow the DNS instructions provided.

---

## 🎯 Quick Fix Script

I've created a PowerShell script that automates Option B. Run it with:

```powershell
.\fix-netlify-deployment.ps1 -SupabaseAnonKey "YOUR_SUPABASE_ANON_KEY_HERE"
```

This script will:
1. Install dependencies
2. Build the project
3. Create/configure Netlify site
4. Set environment variables
5. Deploy to production
6. Add custom domain

---

## 🌐 DNS Configuration for dobeu.net

After adding the domain in Netlify, configure these DNS records at your domain registrar:

### Method 1: Using Netlify's Load Balancer (Recommended)

```
Type: A
Name: @
Value: 75.2.60.5
TTL: 3600 (or Auto)

Type: CNAME
Name: www
Value: <your-site-name>.netlify.app
TTL: 3600 (or Auto)
```

### Method 2: Using CNAME at apex (if supported)

```
Type: CNAME
Name: @
Value: apex-loadbalancer.netlify.com
TTL: 3600

Type: CNAME
Name: www
Value: <your-site-name>.netlify.app
TTL: 3600
```

### Method 3: Use Netlify DNS (Simplest)

1. In Netlify, go to **Domain management**
2. Click **Use Netlify DNS**
3. Update your domain's nameservers to Netlify's nameservers
4. Netlify will auto-configure everything

---

## ✅ Post-Deployment Checklist

After deployment completes:

### Immediate Verification (5 minutes)
- [ ] Site loads at Netlify URL (e.g., dobeu-net.netlify.app)
- [ ] Site loads at https://dobeu.net (after DNS propagates)
- [ ] No blank page (content visible)
- [ ] No console errors in browser (F12)
- [ ] Dark mode toggle works
- [ ] Navigation scrolls to correct sections
- [ ] Contact modal opens

### Functionality Testing (10 minutes)
- [ ] Contact form opens correctly
- [ ] Form validation works (try submitting empty)
- [ ] Form actually submits (test with real data)
- [ ] Check Supabase to confirm lead was recorded
- [ ] Test on mobile device
- [ ] Test in incognito/private mode

### SEO & Performance (15 minutes)
- [ ] Run Lighthouse audit (in Chrome DevTools)
- [ ] Check mobile friendliness: https://search.google.com/test/mobile-friendly
- [ ] Verify SSL certificate is active (padlock icon)
- [ ] Test page load speed: https://pagespeed.web.dev/
- [ ] Check meta tags: https://metatags.io/
- [ ] Verify structured data: https://search.google.com/test/rich-results

### DNS Propagation (Wait 5-30 minutes)
- [ ] Test https://dobeu.net from different devices
- [ ] Test https://www.dobeu.net redirect
- [ ] Check DNS propagation: https://dnschecker.org/#A/dobeu.net

---

## 🔧 Troubleshooting

### Issue: Site still shows blank page

**Solution:**
1. Check browser console for errors (F12)
2. Verify environment variables are set in Netlify
3. Trigger a new deployment: **Deploys** → **Trigger deploy** → **Clear cache and deploy site**

### Issue: "Function not found" or build errors

**Solution:**
1. Check build log in Netlify dashboard
2. Verify `netlify.toml` is in project root
3. Ensure build command is `npm run build` and publish directory is `dist`

### Issue: Form not submitting

**Solution:**
1. Check Supabase connection:
   - Verify URL and anon key are correct
   - Check Supabase project is active
   - Verify RLS policies allow inserts on `leads` table
2. Check browser network tab for failed requests

### Issue: DNS not propagating

**Solution:**
1. Verify DNS records are correct at your registrar
2. Wait longer (can take up to 48 hours, but usually 5-30 minutes)
3. Try clearing DNS cache: `ipconfig /flushdns` (Windows) or `sudo dscacheutil -flushcache` (Mac)
4. Check https://dnschecker.org/#A/dobeu.net

### Issue: Can't find existing Netlify site

**Solution:**
The site might be under a different account:
1. Check all teams in the Netlify dropdown
2. Ask team members if they have access
3. Or create a new site (Option B above)

---

## 📱 Next Steps After Deployment

### Week 1
1. Submit sitemap to Google Search Console
2. Submit sitemap to Bing Webmaster Tools
3. Set up Google Analytics
4. Configure uptime monitoring (UptimeRobot, Pingdom)

### Month 1
1. Create Google Business Profile
2. Set up local business citations
3. Create social media profiles
4. Start SEO content strategy

See `DOBEU_LOCAL_SEO_STRATEGY.md` for detailed marketing plan.

---

## 📞 Need Help?

If you encounter issues:

1. **Check the deployment log** in Netlify dashboard
2. **Check browser console** for JavaScript errors
3. **Verify environment variables** are set correctly
4. **Contact Netlify support** via their dashboard chat

---

## 📝 Files Created

This setup process created:

- `netlify.toml` - Netlify configuration (already in repo)
- `fix-netlify-deployment.ps1` - Automation script
- `NETLIFY_DEPLOYMENT_FIX.md` - Technical details
- `SETUP_DOBEU_NET.md` - This guide

---

## 🎉 Success Criteria

Your deployment is successful when:

✅ Site loads at https://dobeu.net
✅ No errors in browser console
✅ All navigation and features work
✅ Contact form successfully submits to Supabase
✅ SSL certificate is valid
✅ Lighthouse score > 90

---

**Ready to deploy?** Get your Supabase anon key and follow Option A or Option B above!

