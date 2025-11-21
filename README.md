## Dobeu Tech Solutions Marketing Site

Vite + React single-page application that powers the public marketing site for Dobeu Tech Solutions. The project also ships a small suite of Netlify Functions for lead capture, analytics, and operational monitoring.

### Getting Started

```bash
npm install
npm run dev
```

The default dev server runs at `http://localhost:5173`.

### Available Scripts

- `npm run dev` – Vite development server
- `npm run build` – Production build (outputs to `dist/`)
- `npm run preview` – Serves the production build locally
- `npm run lint` – ESLint + TypeScript checks
- `npm run typecheck` – Type-only compilation

### Environment Variables

| Variable | Required | Notes |
| --- | --- | --- |
| `MONGODB_URI` | ✅ | Connection string for MongoDB Atlas. Required by every Netlify Function. |
| `MONGODB_DB_NAME` | ⛔️ (defaults to `dobeunet`) | Optional override for the database name if you use multiple environments. |
| `VITE_ENABLE_HEALTH_MONITOR` | ⛔️ | Set to `true` to force-enable the client-side health monitor in non-production builds (useful when validating the Netlify health function locally). |

Configure these inside Netlify → Site settings → Build & deploy → Environment.

### Production Health Checks

- `/.netlify/functions/health` – Lightweight availability probe (no database access).
- `/.netlify/functions/verify-data` – Deep MongoDB inspection + diagnostics.

The browser now pings only the lightweight `health` endpoint once per minute in production, reducing pressure on MongoDB-backed functions and eliminating the blank-screen crash that occurred when required env variables were missing.

### Troubleshooting

1. **Cursor IDE freeze / unexpected crashes**  
   Caused by serverless modules throwing on import when `MONGODB_URI` was unset. The Mongo helper now validates lazily, so editor tooling can load the files without executing the connection logic.

2. **Site briefly renders then disappears on Netlify**  
   The legacy Supabase bootstrap in an older deploy threw `"Missing Supabase environment variables"`, halting the entire bundle before React mounted. Redeploying from this branch plus the new health check prevents the crash and surfaces configuration issues via the ErrorBoundary.

3. **Health monitor noise during local dev**  
   By default the monitor only runs in production. Flip `VITE_ENABLE_HEALTH_MONITOR=true` in `.env.local` if you need to test the flow against `netlify dev`.

### Deployment

Netlify auto-builds from `main` using the default config inside `netlify.toml`. Make sure to:

- Keep `dist/` out of version control (already handled by `.gitignore`).
- Ensure `public/_redirects` ships with the SPA rewrite.
- Review Netlify deploy logs if you see “function crashed during initialization”; it usually means `MONGODB_URI` is missing or incorrect.
