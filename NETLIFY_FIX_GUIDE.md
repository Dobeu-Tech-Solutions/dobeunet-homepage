# Netlify Deployment Fix Guide

## Problem Summary
Website at https://dobeu.net loads but only shows background color with no content visible.

## Root Cause Analysis
Based on local testing:
- ✅ Build completes successfully
- ✅ JavaScript bundles are valid and generated
- ✅ All assets are present in dist/
- ✅ Dependencies are correctly configured

**Conclusion:** The issue is on Netlify's deployment side, NOT in the codebase.

## Immediate Fix Steps

### Step 1: Clear Netlify Build Cache (CRITICAL)
This is the #1 most common cause of this issue.

1. Go to Netlify Dashboard: https://app.netlify.com/
2. Select your site (dobeu.net)
3. Click "Deploys" in the top menu
4. Click "Trigger deploy" dropdown
5. Select **"Clear cache and deploy site"**
6. Wait for deployment to complete (~2-3 minutes)
7. Test https://dobeu.net again

### Step 2: Verify Build Settings
Go to Site settings → Build & deploy → Build settings

**Current settings (from netlify.toml):**
- Build command: `npm run build`
- Publish directory: `dist`
- Functions directory: `netlify/functions`

**If these don't match, update them:**
```
Build command: npm run build
Publish directory: dist
Functions directory: netlify/functions
```

### Step 3: Check Build Logs
1. Go to Deploys → Click latest deploy
2. Look for these error patterns:

**Common errors:**
```
❌ npm ERR! Missing script: "build"
❌ Error: Cannot find module 'vite'
❌ ELIFECYCLE Command failed with exit code 1
❌ Build exceeded maximum allowed time
❌ JavaScript heap out of memory
```

**Successful build looks like:**
```
✅ vite v5.4.21 building for production...
✅ transforming...
✅ ✓ 1518 modules transformed.
✅ dist/index.html                         9.85 kB
✅ dist/assets/index-*.js                167.56 kB
```

### Step 4: Verify Environment Variables
Go to Site settings → Environment variables

**Required variables:**
- `MONGODB_URI` - Your MongoDB connection string

**To add:**
1. Click "Add a variable"
2. Select "Environment: production"
3. Add key: `MONGODB_URI`
4. Add value: Your MongoDB connection string
5. Click "Create variable"

### Step 5: Test on Netlify Subdomain First
Before testing dobeu.net, verify it works on:
- `https://[your-site-name].netlify.app`

If it works there but not on dobeu.net, it's a DNS/domain configuration issue.

### Step 6: Hard Refresh Browser
After Netlify deploys successfully:

1. Open https://dobeu.net
2. Do a **hard refresh**:
   - Windows/Linux: `Ctrl + Shift + R`
   - Mac: `Cmd + Shift + R`
3. Or clear browser cache:
   - Chrome: Settings → Privacy → Clear browsing data → Cached images and files

## Advanced Debugging

### Check Browser Console
1. Open https://dobeu.net
2. Press F12 (or Cmd+Option+I on Mac)
3. Go to "Console" tab
4. Look for errors:

**JavaScript not loading:**
```
❌ Failed to load resource: net::ERR_FILE_NOT_FOUND
❌ /assets/index-*.js:1 Uncaught SyntaxError
```

**React not mounting:**
```
❌ Target container is not a DOM element
❌ Cannot read property 'render' of undefined
```

### Check Network Tab
1. Press F12 → Network tab
2. Refresh page (Ctrl+R)
3. Look at these requests:

**Should see:**
```
✅ index.html         200  ~10 KB
✅ index-*.js          200  ~168 KB
✅ index-*.css         200  ~58 KB
✅ react-vendor-*.js   200  ~140 KB
✅ lucide-*.js         200  ~7 KB
```

**If you see:**
```
❌ index.html         304  (Not Modified) <- Cached!
❌ index-*.js          404  (Not Found)
❌ index-*.js          500  (Server Error)
```

## Common Issues & Solutions

### Issue 1: Old Cached Build
**Symptoms:** Background color shows but no content

**Fix:**
1. Clear Netlify cache (Step 1 above)
2. Hard refresh browser
3. Clear service worker:
   - Chrome: F12 → Application → Service Workers → Unregister
   - Then refresh

### Issue 2: Build Failing Silently
**Symptoms:** Deploy shows success but site broken

**Fix:**
1. Check full build logs for warnings
2. Increase build resources in netlify.toml:
```toml
[build.environment]
  NODE_OPTIONS = "--max-old-space-size=4096"
```

### Issue 3: Wrong Publish Directory
**Symptoms:** 404 on all assets

**Fix:**
Verify publish directory is `dist` not `build` or `public`

### Issue 4: Service Worker Caching Old Content
**Symptoms:** Site works after clearing cache but breaks again

**Fix:**
1. F12 → Application → Service Workers
2. Click "Unregister"
3. Application → Clear storage → Clear site data
4. Refresh page

### Issue 5: Base Path Issue
**Symptoms:** Assets return 404

**Fix:**
Add to vite.config.ts (if needed):
```typescript
export default defineConfig({
  base: '/', // or base: 'https://dobeu.net/'
  // ... rest of config
})
```

## Verification Checklist

After deploying, verify:

- [ ] Netlify build completed successfully (green checkmark)
- [ ] Build logs show "dist/index.html" created
- [ ] Site loads on *.netlify.app subdomain
- [ ] Site loads on dobeu.net domain
- [ ] Browser console has no errors (F12)
- [ ] All assets return 200 status (F12 → Network)
- [ ] Home page content is visible
- [ ] Navigation works
- [ ] Contact form submits
- [ ] Dark mode toggle works

## If Still Broken After All Steps

### Collect Debugging Information

1. **Netlify Build Log:**
   - Deploys → Latest deploy → Copy full log

2. **Browser Console:**
   - F12 → Console → Screenshot any errors

3. **Network Tab:**
   - F12 → Network → Screenshot showing asset status codes

4. **Site URL:**
   - Both dobeu.net and *.netlify.app URLs

### Contact Support With:
- Build log
- Console errors
- Network tab screenshot
- Description of what you see vs. what's expected

## Prevention for Future Deployments

1. **Always clear cache** when deploying after major changes
2. **Test on *.netlify.app** before checking custom domain
3. **Hard refresh browser** after every deployment
4. **Monitor build logs** for warnings
5. **Set up Netlify notifications** for failed builds

## Quick Command Reference

### Test Build Locally:
```bash
npm install
npm run build
# Should create dist/ folder with index.html
```

### Serve Built Site Locally:
```bash
npm install -g serve
serve -s dist
# Opens at http://localhost:3000
```

### Clear Local Cache:
```bash
rm -rf node_modules dist .netlify
npm install
npm run build
```

## Expected Timeline
- Clear cache and deploy: **2-3 minutes**
- DNS propagation (if domain issue): **5-60 minutes**
- Full cache clear globally: **up to 24 hours**

## Success Indicators
When fixed, you should see:
1. ✅ Full homepage with navigation
2. ✅ Hero section with "Stop Losing Money" headline
3. ✅ Problems and Solutions sections
4. ✅ Social proof section
5. ✅ CTA button working
6. ✅ Footer with legal links

---

**Last Updated:** 2025-11-20
**Status:** Codebase is confirmed working - Issue is deployment/caching related
