# 🚀 Quick Action Checklist - Fix Dobeu.net Now

## Problem
✗ Website shows only background color
✗ Error: "Missing Supabase environment variables"

## Solution in 3 Steps

### Step 1: Get Your Supabase Anon Key (2 minutes)

1. Go to: https://supabase.com/dashboard/project/qmwefqnbeipmbydhfcfj
2. Click **Project Settings** (gear icon in sidebar)
3. Click **API** in the left menu
4. Find **Project API keys** section
5. Copy the **anon** **public** key (the long string starting with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

✓ **Save this key - you'll need it in Step 2**

---

### Step 2A: Fix via Netlify Dashboard (5 minutes) - EASIEST

1. **Go to:** https://app.netlify.com/
2. **Log in** with jswilliamstu@outlook.com
3. **Find your site** (look for "dobeutechsolutions" or check all teams)
4. **Click:** Site settings → Environment variables
5. **Add these two variables:**

   ```
   VITE_SUPABASE_URL = https://qmwefqnbeipmbydhfcfj.supabase.co
   VITE_SUPABASE_ANON_KEY = <paste your key from Step 1>
   ```

6. **Click:** Deploys → Trigger deploy → Clear cache and deploy site
7. **Wait** 1-3 minutes for deployment
8. **Test:** Open https://dobeutechsolutions.netlify.app

✓ **Site should now work!**

---

### Step 2B: Fix via Command Line (If you can't find the site)

```powershell
# Open PowerShell in project directory

# Set your Netlify token
$env:NETLIFY_AUTH_TOKEN = "nfp_TAE9UADqCRUAbzAni2VRaAHg1o1KKCf8f9ce"

# Create new site
netlify init

# Set environment variables (replace YOUR_KEY with actual key from Step 1)
netlify env:set VITE_SUPABASE_URL "https://qmwefqnbeipmbydhfcfj.supabase.co"
netlify env:set VITE_SUPABASE_ANON_KEY "YOUR_KEY_HERE"

# Deploy
netlify deploy --prod
```

✓ **Your new site is live!**

---

### Step 3: Add Custom Domain dobeu.net (10 minutes)

#### In Netlify Dashboard:
1. **Go to:** Site settings → Domain management
2. **Click:** Add a domain
3. **Enter:** `dobeu.net`
4. **Follow** DNS instructions

#### At Your Domain Registrar:
Add these DNS records:

```
Type: A
Name: @
Value: 75.2.60.5

Type: CNAME
Name: www
Value: <your-site-name>.netlify.app
```

✓ **Wait 5-30 minutes for DNS to propagate**
✓ **Then test:** https://dobeu.net

---

## 📋 Verification Checklist

After deployment:

- [ ] Site loads (not blank)
- [ ] No console errors (press F12)
- [ ] Dark mode toggle works
- [ ] Navigation works
- [ ] Contact modal opens
- [ ] Can submit contact form
- [ ] Works on mobile

---

## 🆘 Still Having Issues?

### Can't find Netlify site?
- Check all teams in the Netlify dropdown (top left)
- The site might be under a different account
- Create a new site using Step 2B

### Site still blank after deploy?
1. Check environment variables are saved
2. Trigger a new deploy with "Clear cache"
3. Check browser console for different error

### Can't get Supabase key?
- You need admin access to the Supabase project
- Contact the person who set up Supabase
- Or create a new Supabase project

---

## 📚 Detailed Guides

If you need more information:

- **Full Setup Guide:** `SETUP_DOBEU_NET.md`
- **Technical Details:** `NETLIFY_DEPLOYMENT_FIX.md`
- **Automation Script:** `fix-netlify-deployment.ps1`

---

## ⚡ Fastest Method

**If you have the Supabase anon key right now:**

1. Get key from Supabase dashboard
2. Go to https://app.netlify.com/
3. Find your site → Environment variables
4. Add the two variables
5. Trigger deploy
6. Done! (3 minutes total)

---

**Current Status:**
- ❌ Site broken at: https://dobeutechsolutions.netlify.app
- 🎯 Goal: Working site at https://dobeu.net
- ⏱️ Time to fix: 5-15 minutes (depending on DNS)
- 🔑 What you need: Supabase anon key

**Get started now with Step 1!** 🚀

