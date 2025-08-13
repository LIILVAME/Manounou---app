import React, { useState, useEffect } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import {
  Text,
  Card,
  Title,
  Button,
  List,
  Switch,
  Divider,
  RadioButton,
  Portal,
  Dialog,
  TextInput,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';

interface SettingsScreenProps {
  navigation: {
    navigate: (screen: string) => void;
    goBack: () => void;
  };
}

const SettingsScreen: React.FC<SettingsScreenProps> = ({ navigation }) => {
  const { user, updateProfile } = useAuth();
  const { t, language, changeLanguage } = useI18n();

  // Settings state
  const [notificationsEnabled, setNotificationsEnabled] = useState(true);
  const [pushNotifications, setPushNotifications] = useState(true);
  const [emailNotifications, setEmailNotifications] = useState(true);
  const [darkModeEnabled, setDarkModeEnabled] = useState(false);
  const [autoBackup, setAutoBackup] = useState(true);
  const [biometricAuth, setBiometricAuth] = useState(false);

  // Dialog states
  const [languageDialogVisible, setLanguageDialogVisible] = useState(false);
  const [selectedLanguage, setSelectedLanguage] = useState(language);
  const [deleteAccountDialogVisible, setDeleteAccountDialogVisible] =
    useState(false);
  const [deleteConfirmText, setDeleteConfirmText] = useState('');

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      // Load user settings from AsyncStorage or API
      // This is a mock implementation
    } catch (error) {
      // Error loading settings
    }
  };

  const saveSettings = async () => {
    try {
      // Save settings to AsyncStorage or API
      Alert.alert(t('settings.success'), t('settings.settingsSaved'));
    } catch (error) {
      Alert.alert(t('common.error'), t('settings.errorSavingSettings'));
    }
  };

  const handleLanguageChange = () => {
    setLanguageDialogVisible(true);
  };

  const confirmLanguageChange = async () => {
    await changeLanguage(selectedLanguage);
    setLanguageDialogVisible(false);
    Alert.alert(t('settings.success'), t('settings.languageChanged'));
  };

  const handleDeleteAccount = () => {
    setDeleteAccountDialogVisible(true);
  };

  const confirmDeleteAccount = async () => {
    if (deleteConfirmText.toLowerCase() !== 'delete') {
      Alert.alert(t('common.error'), t('settings.deleteAccountError'));
      return;
    }

    try {
      // Delete account logic here
      Alert.alert(
        t('settings.accountDeleted'),
        t('settings.accountDeletedMessage'),
        [
          {
            text: t('common.ok'),
            onPress: () => {
              // Logout and navigate to auth
              navigation.navigate('Auth');
            },
          },
        ]
      );
    } catch (error) {
      Alert.alert(t('common.error'), t('settings.errorDeletingAccount'));
    }

    setDeleteAccountDialogVisible(false);
    setDeleteConfirmText('');
  };

  const handleExportData = async () => {
    try {
      // Export user data logic
      Alert.alert(t('settings.success'), t('settings.dataExported'));
    } catch (error) {
      Alert.alert(t('common.error'), t('settings.errorExportingData'));
    }
  };

  const handleClearCache = async () => {
    Alert.alert(t('settings.clearCache'), t('settings.clearCacheConfirm'), [
      {
        text: t('common.cancel'),
        style: 'cancel',
      },
      {
        text: t('settings.clear'),
        onPress: async () => {
          try {
            // Clear cache logic
            Alert.alert(t('settings.success'), t('settings.cacheCleared'));
          } catch (error) {
            Alert.alert(t('common.error'), t('settings.errorClearingCache'));
          }
        },
      },
    ]);
  };

  return (
    <ScrollView style={styles.container}>
      {/* Notifications Settings */}
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.sectionTitle}>
            {t('settings.notifications')}
          </Title>

          <List.Item
            title={t('settings.enableNotifications')}
            description={t('settings.enableNotificationsDesc')}
            left={(props: any) => <List.Icon {...props} icon='bell' />}
            right={() => (
              <Switch
                value={notificationsEnabled}
                onValueChange={setNotificationsEnabled}
              />
            )}
          />

          {notificationsEnabled && (
            <>
              <Divider />
              <List.Item
                title={t('settings.pushNotifications')}
                description={t('settings.pushNotificationsDesc')}
                left={(props: any) => <List.Icon {...props} icon='cellphone' />}
                right={() => (
                  <Switch
                    value={pushNotifications}
                    onValueChange={setPushNotifications}
                  />
                )}
              />

              <Divider />
              <List.Item
                title={t('settings.emailNotifications')}
                description={t('settings.emailNotificationsDesc')}
                left={(props: any) => <List.Icon {...props} icon='email' />}
                right={() => (
                  <Switch
                    value={emailNotifications}
                    onValueChange={setEmailNotifications}
                  />
                )}
              />
            </>
          )}
        </Card.Content>
      </Card>

      {/* Appearance Settings */}
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.sectionTitle}>{t('settings.appearance')}</Title>

          <List.Item
            title={t('settings.language')}
            description={t(`settings.currentLanguage.${language}`)}
            left={(props: any) => <List.Icon {...props} icon='translate' />}
            right={(props: any) => (
              <List.Icon {...props} icon='chevron-right' />
            )}
            onPress={handleLanguageChange}
          />

          <Divider />

          <List.Item
            title={t('settings.darkMode')}
            description={t('settings.darkModeDesc')}
            left={(props: any) => (
              <List.Icon {...props} icon='theme-light-dark' />
            )}
            right={() => (
              <Switch
                value={darkModeEnabled}
                onValueChange={setDarkModeEnabled}
              />
            )}
          />
        </Card.Content>
      </Card>

      {/* Security Settings */}
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.sectionTitle}>{t('settings.security')}</Title>

          <List.Item
            title={t('settings.biometricAuth')}
            description={t('settings.biometricAuthDesc')}
            left={(props: any) => <List.Icon {...props} icon='fingerprint' />}
            right={() => (
              <Switch value={biometricAuth} onValueChange={setBiometricAuth} />
            )}
          />

          <Divider />

          <List.Item
            title={t('settings.changePassword')}
            description={t('settings.changePasswordDesc')}
            left={(props: any) => <List.Icon {...props} icon='lock' />}
            right={(props: any) => (
              <List.Icon {...props} icon='chevron-right' />
            )}
            onPress={() => navigation.navigate('ChangePassword')}
          />
        </Card.Content>
      </Card>

      {/* Data & Storage Settings */}
      <Card style={styles.card}>
        <Card.Content>
          <Title style={styles.sectionTitle}>{t('settings.dataStorage')}</Title>

          <List.Item
            title={t('settings.autoBackup')}
            description={t('settings.autoBackupDesc')}
            left={(props: any) => <List.Icon {...props} icon='cloud-upload' />}
            right={() => (
              <Switch value={autoBackup} onValueChange={setAutoBackup} />
            )}
          />

          <Divider />

          <List.Item
            title={t('settings.exportData')}
            description={t('settings.exportDataDesc')}
            left={(props: any) => <List.Icon {...props} icon='download' />}
            right={(props: any) => (
              <List.Icon {...props} icon='chevron-right' />
            )}
            onPress={handleExportData}
          />

          <Divider />

          <List.Item
            title={t('settings.clearCache')}
            description={t('settings.clearCacheDesc')}
            left={(props: any) => <List.Icon {...props} icon='delete' />}
            right={(props: any) => (
              <List.Icon {...props} icon='chevron-right' />
            )}
            onPress={handleClearCache}
          />
        </Card.Content>
      </Card>

      {/* Danger Zone */}
      <Card style={[styles.card, styles.dangerCard]}>
        <Card.Content>
          <Title style={[styles.sectionTitle, styles.dangerTitle]}>
            {t('settings.dangerZone')}
          </Title>

          <List.Item
            title={t('settings.deleteAccount')}
            description={t('settings.deleteAccountDesc')}
            titleStyle={styles.dangerText}
            left={(props: any) => (
              <List.Icon
                {...props}
                icon='account-remove'
                color={colors.error}
              />
            )}
            right={(props: any) => (
              <List.Icon {...props} icon='chevron-right' />
            )}
            onPress={handleDeleteAccount}
          />
        </Card.Content>
      </Card>

      {/* Save Button */}
      <View style={styles.saveButtonContainer}>
        <Button
          mode='contained'
          onPress={saveSettings}
          style={styles.saveButton}
        >
          {t('settings.saveSettings')}
        </Button>
      </View>

      {/* Language Selection Dialog */}
      <Portal>
        <Dialog
          visible={languageDialogVisible}
          onDismiss={() => setLanguageDialogVisible(false)}
        >
          <Dialog.Title>{t('settings.selectLanguage')}</Dialog.Title>
          <Dialog.Content>
            <RadioButton.Group
              onValueChange={(value: string) =>
                setSelectedLanguage(value as 'fr' | 'en')
              }
              value={selectedLanguage}
            >
              <RadioButton.Item label='Français' value='fr' />
              <RadioButton.Item label='English' value='en' />
            </RadioButton.Group>
          </Dialog.Content>
          <Dialog.Actions>
            <Button onPress={() => setLanguageDialogVisible(false)}>
              {t('common.cancel')}
            </Button>
            <Button onPress={confirmLanguageChange}>
              {t('common.confirm')}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>

      {/* Delete Account Dialog */}
      <Portal>
        <Dialog
          visible={deleteAccountDialogVisible}
          onDismiss={() => setDeleteAccountDialogVisible(false)}
        >
          <Dialog.Title>{t('settings.deleteAccountConfirm')}</Dialog.Title>
          <Dialog.Content>
            <Text style={styles.deleteWarning}>
              {t('settings.deleteAccountWarning')}
            </Text>
            <TextInput
              label={t('settings.typeDelete')}
              value={deleteConfirmText}
              onChangeText={setDeleteConfirmText}
              style={styles.deleteInput}
            />
          </Dialog.Content>
          <Dialog.Actions>
            <Button
              onPress={() => {
                setDeleteAccountDialogVisible(false);
                setDeleteConfirmText('');
              }}
            >
              {t('common.cancel')}
            </Button>
            <Button
              onPress={confirmDeleteAccount}
              textColor={colors.error}>
              {t('settings.deleteAccount')}
            </Button>
          </Dialog.Actions>
        </Dialog>
      </Portal>

      <View style={styles.bottomSpacing} />
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  card: {
    margin: spacing.md,
    marginBottom: spacing.sm,
  },
  dangerCard: {
    borderColor: colors.error + '30',
    borderWidth: 1,
  },
  sectionTitle: {
    ...typography.h4,
    marginBottom: spacing.md,
  },
  dangerTitle: {
    color: colors.error,
  },
  dangerText: {
    color: colors.error,
  },
  saveButtonContainer: {
    margin: spacing.md,
  },
  saveButton: {
    marginVertical: spacing.md,
  },
  deleteWarning: {
    ...typography.body,
    color: colors.error,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  deleteInput: {
    marginTop: spacing.md,
  },
  bottomSpacing: {
    height: spacing.xl,
  },
});

export default SettingsScreen;
