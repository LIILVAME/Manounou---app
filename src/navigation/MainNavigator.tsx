import React from 'react';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createStackNavigator } from '@react-navigation/stack';
import { useTheme } from 'react-native-paper';
import Icon from 'react-native-vector-icons/MaterialCommunityIcons';

// Import screens
import DashboardScreen from '../screens/main/DashboardScreen';
import ChildrenScreen from '../screens/main/ChildrenScreen';
import PlanningScreen from '../screens/main/PlanningScreen';
import DocumentsScreen from '../screens/main/DocumentsScreen';
import VacationsScreen from '../screens/main/VacationsScreen';
import ProfileScreen from '../screens/main/ProfileScreen';
import SettingsScreen from '../screens/main/SettingsScreen';

// Import types
import { MainTabParamList } from '../types';
import { useI18n } from '../contexts/I18nContext';

const Tab = createBottomTabNavigator<MainTabParamList>();
const Stack = createStackNavigator();

const MainTabNavigator: React.FC = () => {
  const theme = useTheme();
  const { t } = useI18n();

  return (
    <Tab.Navigator
      screenOptions={({ route }) => ({
        tabBarIcon: ({ focused, color, size }) => {
          let iconName: string;

          switch (route.name) {
            case 'Dashboard':
              iconName = focused ? 'view-dashboard' : 'view-dashboard-outline';
              break;
            case 'Children':
              iconName = focused ? 'account-child' : 'account-child-outline';
              break;
            case 'Schedule':
              iconName = focused ? 'calendar' : 'calendar-outline';
              break;
            case 'Documents':
              iconName = focused ? 'file-document' : 'file-document-outline';
              break;
            case 'Vacations':
              iconName = focused ? 'beach' : 'beach';
              break;
            case 'Profile':
              iconName = focused ? 'account' : 'account-outline';
              break;
            default:
              iconName = 'circle';
          }

          return <Icon name={iconName} size={size} color={color} />;
        },
        tabBarActiveTintColor: theme.colors.primary,
        tabBarInactiveTintColor: theme.colors.onSurfaceVariant,
        tabBarStyle: {
          backgroundColor: theme.colors.surface,
          borderTopColor: theme.colors.outline,
        },
        headerStyle: {
          backgroundColor: theme.colors.surface,
        },
        headerTintColor: theme.colors.onSurface,
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      })}
    >
      <Tab.Screen
        name="Dashboard"
        component={DashboardScreen}
        options={{
          title: t('navigation.dashboard'),
          headerTitle: t('navigation.dashboard'),
        }}
      />
      <Tab.Screen
        name="Children"
        component={ChildrenScreen}
        options={{
          title: t('navigation.children'),
          headerTitle: t('navigation.children'),
        }}
      />
      <Tab.Screen
        name="Schedule"
        component={PlanningScreen as any}
        options={{
          title: t('navigation.planning'),
          headerTitle: t('navigation.planning'),
        }}
      />
      <Tab.Screen
        name="Documents"
        component={DocumentsScreen as any}
        options={{
          title: t('navigation.documents'),
          headerTitle: t('navigation.documents'),
        }}
      />
      <Tab.Screen
        name="Vacations"
        component={VacationsScreen}
        options={{
          title: t('navigation.vacations'),
          headerTitle: t('navigation.vacations'),
        }}
      />
      <Tab.Screen
        name="Profile"
        component={ProfileScreen}
        options={{
          title: t('navigation.profile'),
          headerTitle: t('navigation.profile'),
        }}
      />
    </Tab.Navigator>
  );
};

const MainStackNavigator: React.FC = () => {
  const theme = useTheme();
  const { t } = useI18n();

  return (
    <Stack.Navigator
      screenOptions={{
        headerStyle: {
          backgroundColor: theme.colors.surface,
        },
        headerTintColor: theme.colors.onSurface,
        headerTitleStyle: {
          fontWeight: 'bold',
        },
      }}
    >
      <Stack.Screen
        name="MainTabs"
        component={MainTabNavigator}
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="Settings"
        component={SettingsScreen}
        options={{
          title: t('navigation.settings'),
          headerTitle: t('navigation.settings'),
        }}
      />
    </Stack.Navigator>
  );
};

export default MainStackNavigator;
