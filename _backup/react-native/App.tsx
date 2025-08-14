import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { Provider as PaperProvider } from 'react-native-paper';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { AuthProvider } from './src/contexts/AuthContext';
import { I18nProvider } from './src/contexts/I18nContext';
import AppNavigator from './src/navigation/AppNavigator';
import { theme } from './src/constants/theme';

const App: React.FC = () => {
  return (
    <SafeAreaProvider>
      <PaperProvider theme={theme}>
        <I18nProvider>
          <AuthProvider>
            <NavigationContainer>
              <AppNavigator />
            </NavigationContainer>
          </AuthProvider>
        </I18nProvider>
      </PaperProvider>
    </SafeAreaProvider>
  );
};

export default App;
