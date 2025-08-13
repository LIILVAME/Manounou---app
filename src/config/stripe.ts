import { StripeProvider } from '@stripe/stripe-react-native';

export const STRIPE_PUBLISHABLE_KEY = 'YOUR_STRIPE_PUBLISHABLE_KEY';

export const stripeConfig = {
  publishableKey: STRIPE_PUBLISHABLE_KEY,
  merchantIdentifier: 'merchant.com.manounou.app',
  urlScheme: 'manounou-app',
};

export default stripeConfig;
