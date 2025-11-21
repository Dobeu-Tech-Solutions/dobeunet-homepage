import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.tsx';
import './index.css';
import { ErrorBoundary } from './components/ErrorBoundary';
import { ToastProvider } from './components/ToastContainer';
import { registerServiceWorker } from './utils/register-service-worker';
import { startConnectionMonitoring } from './utils/connection-monitor';

const enableHealthMonitor = import.meta.env.VITE_ENABLE_HEALTH_MONITOR === 'true';

// Service worker should only be registered in production.
const shouldRegisterServiceWorker = import.meta.env.PROD;
// Health monitor can be enabled in production or when explicitly requested (e.g., for testing/staging).
const shouldStartHealthMonitor = import.meta.env.PROD || enableHealthMonitor;

if (shouldRegisterServiceWorker) {
  registerServiceWorker();
}

if (shouldStartHealthMonitor) {
  startConnectionMonitoring();
}

createRoot(document.getElementById('root')!).render(
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
