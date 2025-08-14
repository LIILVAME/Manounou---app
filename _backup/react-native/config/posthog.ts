import PostHog from 'posthog-react-native';

// Configuration PostHog
const POSTHOG_API_KEY = 'YOUR_POSTHOG_API_KEY'; // Remplacez par votre clé API PostHog
const POSTHOG_HOST = 'https://app.posthog.com'; // ou votre instance PostHog personnalisée

// Initialisation PostHog
const posthog = new PostHog(POSTHOG_API_KEY, {
  host: POSTHOG_HOST,
});

export default posthog;
