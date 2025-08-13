import React from 'react';
import { createStackNavigator } from '@react-navigation/stack';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import Icon from 'react-native-vector-icons/MaterialIcons';
import { useAuth } from '../contexts/AuthContext';
import {
  RootStackParamList,
  AuthStackParamList,
  MainTabParamList,
} from '../types';
import { colors } from '../constants/theme';

// Auth Screens
import LoginScreen from '../screens/auth/LoginScreen';
import RegisterScreen from '../screens/auth/RegisterScreen';
import ForgotPasswordScreen from '../screens/auth/ForgotPasswordScreen';
import OnboardingScreen from '../screens/onboarding/OnboardingScreen';

// Main Screens
import DashboardScreen from '../screens/main/DashboardScreen';
import ChildrenScreen from '../screens/main/ChildrenScreen';
import PlanningScreen from '../screens/main/PlanningScreen';
import DocumentsScreen from '../screens/main/DocumentsScreen';
import VacationsScreen from '../screens/main/VacationsScreen';
import ProfileScreen from '../screens/main/ProfileScreen';

// Loading Screen
import LoadingScreen from '../screens/LoadingScreen';

const RootStack = createStackNavigator<RootStackParamList>();
const AuthStack = createStackNavigator<AuthStackParamList>();
const MainTab = createBottomTabNavigator<MainTabParamList>();

const AuthNavigator = () => {
  return (
    <AuthStack.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <AuthStack.Screen name="Login" component={LoginScreen} />
      <AuthStack.Screen name="Register" component={RegisterScreen} />
      <AuthStack.Screen
        name="ForgotPassword"
        component={ForgotPasswordScreen}
      />
    </AuthStack.Navigator>
  );
};

const MainNavigator = () => {
  return (
    <MainTab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string;

          switch (route.name) {
            case 'Dashboard':
              iconName = 'dashboard';
              break;
            case 'Children':
              iconName = 'child-care';
              break;
            case 'Schedule':
              iconName = 'schedule';
              break;
            case 'Documents':
              iconName = 'folder';
              break;
            case 'Vacations':
              iconName = 'beach-access';
              break;
            case 'Profile':
              iconName = 'person';
              break;
            default:
              iconName = 'help';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.textSecondary,
        tabBarStyle: {
          backgroundColor: colors.surface,
          borderTopColor: colors.border,
        },
        headerStyle: {
          backgroundColor: colors.primary,
        },
        headerTintColor: colors.surface,
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}
    >
      <MainTab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{ title: 'Tableau de bord' }}
      />
      <MainTab.Screen
        name="Children"
        component={ChildrenScreen}
        options={{ title: 'Enfants' }}
      />
      <MainTab.Screen
        name="Schedule"
        component={PlanningScreen as any}
        options={{ title: 'Planning' }}
      />
      <MainTab.Screen
        name="Documents"
        component={DocumentsScreen as any}
        options={{ title: 'Documents' }}
      />
      <MainTab.Screen
        name="Vacations"
        component={VacationsScreen}
        options={{ title: 'Vacances' }}
      />
      <MainTab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{ title: 'Profil' }}
      />
    </MainTab.Navigator>
  );
};

const AppNavigator = () => {
  const { loading, user } = useAuth();

  if (loading) {
    return <LoadingScreen />;
  }

  return (
    <RootStack.Navigator screenOptions={{ headerShown: false }}>
      {!user ? (
        <RootStack.Screen name="Auth" component={AuthNavigator} />
      ) : !user?.plan ? (
        <RootStack.Screen name="Onboarding" component={OnboardingScreen} />
      ) : (
        <RootStack.Screen name="Main" component={MainNavigator} />
      )}
    </RootStack.Navigator>
  );
};

export default AppNavigator;
