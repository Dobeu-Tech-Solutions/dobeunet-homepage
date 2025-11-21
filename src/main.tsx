import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App.tsx';
import './index.css';
import { ErrorBoundary } from './components/ErrorBoundary';
import { ToastProvider } from './components/ToastContainer';
import { startConnectionMonitoring } from './utils/connection-monitor';
import { cleanupLegacyServiceWorkers } from './utils/legacy-service-worker-cleanup';

if (import.meta.env.PROD) {
  void cleanupLegacyServiceWorkers();
}
startConnectionMonitoring();

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
