import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert, Image } from 'react-native';
import {
  Text,
  Card,
  Title,
  Paragraph,
  Button,
  IconButton,
  Chip,
  Avatar,
  List,
  Switch,
  Divider,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { User, Pack } from '../../types';

interface ProfileScreenProps {
  navigation: {
    navigate: (screen: string) => void;
  };
}

const ProfileScreen: React.FC<ProfileScreenProps> = ({ navigation }) => {
  const { user, signOut, updateProfile } = useAuth();
  const { t, language, changeLanguage } = useI18n();
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(false);
  const [currentPack, setCurrentPack] = useState<Pack | null>(null);

  useEffect(() => {
    loadUserSettings();
  }, []);

  const loadUserSettings = async () => {
    try {
      // Load user settings and pack information
      const userPack = user?.plan || 'free';
      const mockPack: Pack = {
        id: '1',
        name: userPack,
        price: userPack === 'free' ? 0 : userPack === 'starter' ? 9.99 : 19.99,
        features: [
          userPack === 'free'
            ? "Jusqu'à 1 enfant"
            : userPack === 'starter'
            ? "Jusqu'à 3 enfants"
            : 'Enfants illimités',
          userPack === 'free'
            ? '5 documents max'
            : userPack === 'starter'
            ? '50 documents max'
            : 'Documents illimités',
          'Planning de base',
          ...(userPack !== 'free' ? ['Support prioritaire'] : []),
          ...(userPack === 'full' ? ['Rapports avancés', 'API access'] : []),
        ],
        maxChildren: userPack === 'free' ? 1 : userPack === 'starter' ? 3 : -1,
        maxDocuments:
          userPack === 'free' ? 5 : userPack === 'starter' ? 50 : -1,
      };
      setCurrentPack(mockPack);
    } catch (error) {
      // Error loading user settings
    }
  };

  const handleLogout = () => {
    Alert.alert(
      t('profile.logoutConfirmTitle'),
      t('profile.logoutConfirmMessage'),
      [
        {
          text: t('common.cancel'),
          style: 'cancel',
        },
        {
          text: t('profile.logout'),
          style: 'destructive',
          onPress: signOut,
        },
      ]
    );
  };

  const handleEditProfile = () => {
    navigation.navigate('EditProfile');
  };

  const handleChangePassword = () => {
    navigation.navigate('ChangePassword');
  };

  const handleUpgradePack = () => {
    navigation.navigate('PackSelection');
  };

  const toggleNotifications = async (enabled: boolean) => {
    setNotificationsEnabled(enabled);
    // Here you would save the setting to AsyncStorage or API
  };

  const toggleDarkMode = async (enabled: boolean) => {
    setDarkModeEnabled(enabled);
    // Here you would save the setting and apply theme changes
  };

  const handleLanguageChange = () => {
    const newLanguage = language === 'fr' ? 'en' : 'fr';
    changeLanguage(newLanguage);
  };

  const getPackColor = (packName: string) => {
    switch (packName) {
      case 'free':
        return colors.textSecondary;
      case 'starter':
        return colors.warning;
      case 'full':
        return colors.success;
      default:
        return colors.textSecondary;
    }
  };

  const getPackIcon = (packName: string) => {
    switch (packName) {
      case 'free':
        return 'gift';
      case 'starter':
        return 'star';
      case 'full':
        return 'crown';
      default:
        return 'package';
    }
  };

  if (!user) {
    return (
      <View style={styles.container}>
        <Text>{t('common.loading')}</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      {/* Profile Header */}
      <Card style={styles.profileCard}>
        <Card.Content style={styles.profileContent}>
          <View style={styles.profileHeader}>
            <Avatar.Text
              size={80}
              label={
                user.displayName
                  ? user.displayName.substring(0, 2).toUpperCase()
                  : 'U'
              }
              style={styles.avatar}
            />
            <View style={styles.profileInfo}>
              <Title style={styles.userName}>
                {user.displayName || 'Utilisateur'}
              </Title>
              <Text style={styles.userEmail}>{user.email}</Text>
              <Text style={styles.userRole}>{t(`roles.${user.role}`)}</Text>
            </View>
            <IconButton icon="pencil" size={24} onPress={handleEditProfile} />
          </View>
        </Card.Content>
      </Card>

      {/* Current Pack */}
      {currentPack && (
        <Card style={styles.packCard}>
          <Card.Content>
            <View style={styles.packHeader}>
              <View style={styles.packInfo}>
                <Title style={styles.packTitle}>
                  {t(`packs.${currentPack.name}.name`)}
                </Title>
                <Text style={styles.packPrice}>
                  {currentPack.price === 0
                    ? t('packs.free.price')
                    : `${currentPack.price}€/mois`}
                </Text>
              </View>
              <Chip
                icon={getPackIcon(currentPack.name)}
                style={[
                  styles.packChip,
                  { backgroundColor: getPackColor(currentPack.name) + '20' },
                ]}
                textStyle={[
                  styles.packChipText,
                  { color: getPackColor(currentPack.name) },
                ]}
              >
                {t(`packs.${currentPack.name}.name`)}
              </Chip>
            </View>

            <View style={styles.packFeatures}>
              {currentPack.features.map((feature: string, index: number) => (
                <Text key={index} style={styles.packFeature}>
                  • {feature}
                </Text>
              ))}
            </View>

            {currentPack.name !== 'full' && (
              <Button
                mode="contained"
                onPress={handleUpgradePack}
                style={styles.upgradeButton}
              >
                {t('profile.upgradePack')}
              </Button>
            )}
          </Card.Content>
        </Card>
      )}

      {/* Settings */}
      <Card style={styles.settingsCard}>
        <Card.Content>
          <Title style={styles.sectionTitle}>{t('profile.settings')}</Title>

          <List.Item
            title={t('profile.notifications')}
            description={t('profile.notificationsDescription')}
            left={(props: any) => <List.Icon {...props} icon="bell" />}
            right={() => (
              <Switch
                value={notificationsEnabled}
                onValueChange={toggleNotifications}
              />
            )}
          />

          <Divider />

          <List.Item
            title={t('profile.language')}
            description={t(`profile.currentLanguage.${language}`)}
            left={(props: any) => <List.Icon {...props} icon="translate" />}
            right={(props: any) => (
              <List.Icon {...props} icon="chevron-right" />
            )}
            onPress={handleLanguageChange}
          />

          <Divider />

          <List.Item
            title={t('profile.darkMode')}
            description={t('profile.darkModeDescription')}
            left={(props: any) => (
              <List.Icon {...props} icon="theme-light-dark" />
            )}
            right={() => (
              <Switch value={darkModeEnabled} onValueChange={toggleDarkMode} />
            )}
          />
        </Card.Content>
      </Card>

      {/* Account Actions */}
      <Card style={styles.actionsCard}>
        <Card.Content>
          <Title style={styles.sectionTitle}>{t('profile.account')}</Title>

          <List.Item
            title={t('profile.changePassword')}
            left={(props: any) => <List.Icon {...props} icon="lock" />}
            right={(props: any) => (
              <List.Icon {...props} icon="chevron-right" />
            )}
            onPress={handleChangePassword}
          />

          <Divider />

          <List.Item
            title={t('profile.help')}
            left={(props: any) => <List.Icon {...props} icon="help-circle" />}
            right={(props: any) => (
              <List.Icon {...props} icon="chevron-right" />
            )}
            onPress={() => navigation.navigate('Help')}
          />

          <Divider />

          <List.Item
            title={t('profile.about')}
            left={(props: any) => <List.Icon {...props} icon="information" />}
            right={(props: any) => (
              <List.Icon {...props} icon="chevron-right" />
            )}
            onPress={() => navigation.navigate('About')}
          />

          <Divider />

          <List.Item
            title={t('profile.logout')}
            titleStyle={styles.logoutText}
            left={(props: any) => (
              <List.Icon {...props} icon="logout" color={colors.error} />
            )}
            onPress={handleLogout}
          />
        </Card.Content>
      </Card>

      <View style={styles.bottomSpacing} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  profileCard: {
    margin: spacing.md,
    marginBottom: spacing.sm,
  },
  profileContent: {
    padding: spacing.md,
  },
  profileHeader: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  avatar: {
    backgroundColor: colors.primary,
  },
  profileInfo: {
    flex: 1,
    marginLeft: spacing.md,
  },
  userName: {
    ...typography.h4,
    marginBottom: spacing.xs,
  },
  userEmail: {
    ...typography.body,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  userRole: {
    ...typography.caption,
    color: colors.primary,
    fontWeight: 'bold',
    textTransform: 'uppercase',
  },
  packCard: {
    margin: spacing.md,
    marginTop: spacing.sm,
    marginBottom: spacing.sm,
  },
  packHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
  },
  packInfo: {
    flex: 1,
  },
  packTitle: {
    ...typography.h4,
    marginBottom: spacing.xs,
  },
  packPrice: {
    ...typography.body,
    color: colors.primary,
    fontWeight: 'bold',
  },
  packChip: {
    height: 32,
  },
  packChipText: {
    fontSize: 12,
    fontWeight: 'bold',
  },
  packFeatures: {
    marginBottom: spacing.md,
  },
  packFeature: {
    ...typography.body,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  upgradeButton: {
    marginTop: spacing.sm,
  },
  settingsCard: {
    margin: spacing.md,
    marginTop: spacing.sm,
    marginBottom: spacing.sm,
  },
  actionsCard: {
    margin: spacing.md,
    marginTop: spacing.sm,
  },
  sectionTitle: {
    ...typography.h4,
    marginBottom: spacing.md,
  },
  logoutText: {
    color: colors.error,
  },
  bottomSpacing: {
    height: spacing.xl,
  },
});

export default ProfileScreen;
