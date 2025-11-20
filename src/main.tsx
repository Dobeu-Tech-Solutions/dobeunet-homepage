import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.tsx';
import './index.css';
import { ErrorBoundary } from './components/ErrorBoundary';
import { ToastProvider } from './components/ToastContainer';
import { registerServiceWorker } from './utils/register-service-worker';
import { startConnectionMonitoring } from './utils/connection-monitor';

// Global error handler for uncaught errors
window.addEventListener('error', (event) => {
  console.error('[Global Error]', event.error || event.message, event.filename, event.lineno);
});

window.addEventListener('unhandledrejection', (event) => {
  console.error('[Unhandled Promise Rejection]', event.reason);
});

// Function to render the app with error handling
function renderApp() {
  const rootElement = document.getElementById('root');
  
  if (!rootElement) {
    console.error('[Fatal] Root element not found!');
    document.body.innerHTML = `
      <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background: #0f172a; color: #f8fafc; font-family: system-ui, sans-serif; padding: 2rem;">
        <div style="text-align: center; max-width: 600px;">
          <h1 style="font-size: 2rem; margin-bottom: 1rem;">Application Error</h1>
          <p style="font-size: 1.125rem; margin-bottom: 2rem;">Unable to initialize the application. Please refresh the page.</p>
          <button onclick="window.location.reload()" style="background: #06b6d4; color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 0.5rem; font-size: 1rem; cursor: pointer;">
            Refresh Page
          </button>
        </div>
      </div>
    `;
    return;
  }

  try {
    const root = createRoot(rootElement);
    
    root.render(
      <StrictMode>
        <BrowserRouter>
          <ErrorBoundary>
            <ToastProvider>
              <App />
            </ToastProvider>
          </ErrorBoundary>
        </BrowserRouter>
      </StrictMode>
    );

    // Register service worker after React mounts successfully
    // This prevents service worker issues from blocking the app
    if (import.meta.env.PROD) {
      // Defer service worker registration to avoid blocking initial render
      setTimeout(() => {
        try {
          registerServiceWorker();
        } catch (error) {
          console.warn('[Service Worker] Registration deferred due to error:', error);
        }
      }, 1000);

      // Start connection monitoring after a delay
      setTimeout(() => {
        try {
          startConnectionMonitoring();
        } catch (error) {
          console.warn('[Connection Monitor] Start deferred due to error:', error);
        }
      }, 2000);
    } else {
      // In development, start immediately
      registerServiceWorker();
      startConnectionMonitoring();
    }
  } catch (error) {
    console.error('[Fatal] Failed to render React app:', error);
    rootElement.innerHTML = `
      <div style="min-height: 100vh; display: flex; align-items: center; justify-content: center; background: #0f172a; color: #f8fafc; font-family: system-ui, sans-serif; padding: 2rem;">
        <div style="text-align: center; max-width: 600px;">
          <h1 style="font-size: 2rem; margin-bottom: 1rem;">Application Error</h1>
          <p style="font-size: 1.125rem; margin-bottom: 1rem;">Failed to initialize the application.</p>
          <pre style="background: #1e293b; padding: 1rem; border-radius: 0.5rem; overflow-x: auto; text-align: left; margin-bottom: 2rem; font-size: 0.875rem;">
${error instanceof Error ? error.message : String(error)}
          </pre>
          <button onclick="window.location.reload()" style="background: #06b6d4; color: white; border: none; padding: 0.75rem 1.5rem; border-radius: 0.5rem; font-size: 1rem; cursor: pointer;">
            Refresh Page
          </button>
        </div>
      </div>
    `;
  }
}

// Wait for DOM to be ready
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', renderApp);
} else {
  // DOM is already ready
  renderApp();
}
