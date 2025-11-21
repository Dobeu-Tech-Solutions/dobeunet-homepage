import { useEffect } from 'react';
import Intercom from '@intercom/messenger-js-sdk';

/**
 * Delay (in milliseconds) before initializing Intercom.
 * This ensures the page is fully interactive before loading the chat widget,
 * preventing it from blocking initial page load and improving Core Web Vitals.
 */
const INTERCOM_INIT_DELAY_MS = 2000;

/**
 * Intercom Chat Component
 *
 * Integrates Intercom Messenger for customer support and engagement.
 * Deferred initialization to avoid blocking page load.
 */
export default function IntercomChat() {
  useEffect(() => {
    // Defer Intercom initialization until after page is interactive
    const timeoutId = setTimeout(() => {
      try {
        // Initialize Intercom with app ID
        Intercom({
          app_id: 'xu0gfiqb',
        });
      } catch {
        // Gracefully handle Intercom initialization errors
        // Don't break the app if Intercom fails to load
        // Removed console.error to reduce noise in production
      }
    }, INTERCOM_INIT_DELAY_MS);

    return () => {
      clearTimeout(timeoutId);
    };
  }, []);

  // This component doesn't render anything visible
  // Intercom messenger appears as a widget on the page
  return null;
}
