
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.lovable.5cceaa49180a49b9a8c25aba958bec2d',
  appName: 'Photo Flow Reserve',
  webDir: 'dist',
  server: {
    url: 'https://5cceaa49-180a-49b9-a8c2-5aba958bec2d.lovableproject.com?forceHideBadge=true',
    cleartext: true
  },
  ios: {
    contentInset: 'always',
  },
  android: {
    backgroundColor: "#F4632D",
    allowMixedContent: true
  }
};

export default config;
