export function registerServiceWorker(): void {
  // Only register in production and if service workers are supported
  if (typeof window === 'undefined' || !('serviceWorker' in navigator) || !import.meta.env.PROD) {
    return;
  }

  // Check if we're already registered to avoid duplicate registrations
  if (navigator.serviceWorker.controller) {
    console.log('[Service Worker] Already active');
    return;
  }

  // Use requestIdleCallback if available, otherwise setTimeout
  const scheduleRegistration = (callback: () => void) => {
    if ('requestIdleCallback' in window) {
      requestIdleCallback(callback, { timeout: 2000 });
    } else {
      setTimeout(callback, 1000);
    }
  };

  scheduleRegistration(() => {
    navigator.serviceWorker
      .register('/service-worker.js', {
        scope: '/',
        updateViaCache: 'none', // Always check for updates
      })
      .then((registration) => {
        console.log('[Service Worker] Registered successfully:', registration.scope);

        // Check for updates immediately
        registration.update().catch((error) => {
          console.warn('[Service Worker] Update check failed:', error);
        });

        registration.addEventListener('updatefound', () => {
          const newWorker = registration.installing;
          if (newWorker) {
            newWorker.addEventListener('statechange', () => {
              if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                console.log('[Service Worker] New content available, please refresh.');
                // Don't auto-reload, let user decide
              }
            });
          }
        });
      })
      .catch((error) => {
        // Don't throw - service worker is optional
        console.warn('[Service Worker] Registration failed (non-critical):', error);
      });

    // Handle controller changes (when a new service worker takes control)
    let refreshing = false;
    navigator.serviceWorker.addEventListener('controllerchange', () => {
      if (!refreshing) {
        refreshing = true;
        // Only reload if we're not already refreshing
        console.log('[Service Worker] New controller activated, reloading...');
        window.location.reload();
      }
    });
  });
}

export function unregisterServiceWorker(): Promise<boolean> {
  if ('serviceWorker' in navigator) {
    return navigator.serviceWorker.ready
      .then((registration) => {
        return registration.unregister();
      })
      .catch((error) => {
        console.error('[Service Worker] Unregistration failed:', error);
        return false;
      });
  }
  return Promise.resolve(false);
}
