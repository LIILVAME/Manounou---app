import React, { useState } from 'react';
import { View, StyleSheet, ScrollView, Alert } from 'react-native';
import {
  Text,
  Button,
  Card,
  Title,
  Paragraph,
  RadioButton,
  Divider,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { useI18n } from '../../contexts/I18nContext';
import { colors, spacing, typography } from '../../constants/theme';
import { UserRole, Pack } from '../../types';

interface OnboardingScreenProps {
  navigation: any;
}

const OnboardingScreen: React.FC<OnboardingScreenProps> = ({ navigation }) => {
  const { updateProfile } = useAuth();
  const { t } = useI18n();
  const [selectedRole, setSelectedRole] = useState<UserRole>('parent');
  const [selectedPack, setSelectedPack] = useState<string>('free');
  const [loading, setLoading] = useState(false);

  const packs = [
    {
      id: 'free',
      name: t('packs.free.name'),
      price: t('packs.free.price'),
      features: [
        t('packs.free.features.children'),
        t('packs.free.features.planning'),
        t('packs.free.features.documents'),
      ],
    },
    {
      id: 'starter',
      name: t('packs.starter.name'),
      price: t('packs.starter.price'),
      features: [
        t('packs.starter.features.children'),
        t('packs.starter.features.planning'),
        t('packs.starter.features.documents'),
        t('packs.starter.features.notifications'),
      ],
    },
    {
      id: 'full',
      name: t('packs.full.name'),
      price: t('packs.full.price'),
      features: [
        t('packs.full.features.unlimited'),
        t('packs.full.features.advanced'),
        t('packs.full.features.priority'),
        t('packs.full.features.export'),
      ],
    },
  ];

  const handleContinue = async () => {
    try {
      setLoading(true);
      await updateProfile({
        role: selectedRole,
        plan: selectedPack as 'free' | 'starter' | 'full',
      });
      // Navigation will be handled by AppNavigator based on updated user state
    } catch (error: any) {
      Alert.alert(
        t('common.error'),
        error.message || t('errors.updateProfile')
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.content}>
        <View style={styles.header}>
          <Title style={styles.title}>{t('onboarding.welcome')}</Title>
          <Paragraph style={styles.subtitle}>
            {t('onboarding.subtitle')}
          </Paragraph>
        </View>

        {/* Role Selection */}
        <Card style={styles.card}>
          <Card.Content>
            <Title style={styles.sectionTitle}>
              {t('onboarding.selectRole')}
            </Title>
            <RadioButton.Group
              onValueChange={value => setSelectedRole(value as UserRole)}
              value={selectedRole}
            >
              <View style={styles.radioItem}>
                <RadioButton value="parent" />
                <View style={styles.radioContent}>
                  <Text style={styles.radioTitle}>{t('roles.parent')}</Text>
                  <Text style={styles.radioDescription}>
                    {t('onboarding.parentDescription')}
                  </Text>
                </View>
              </View>
              <View style={styles.radioItem}>
                <RadioButton value="nanny" />
                <View style={styles.radioContent}>
                  <Text style={styles.radioTitle}>{t('roles.nanny')}</Text>
                  <Text style={styles.radioDescription}>
                    {t('onboarding.nannyDescription')}
                  </Text>
                </View>
              </View>
            </RadioButton.Group>
          </Card.Content>
        </Card>

        <Divider style={styles.divider} />

        {/* Pack Selection */}
        <Card style={styles.card}>
          <Card.Content>
            <Title style={styles.sectionTitle}>
              {t('onboarding.selectPack')}
            </Title>
            <RadioButton.Group
              onValueChange={value => setSelectedPack(value)}
              value={selectedPack}
            >
              {packs.map(pack => (
                <View key={pack.id} style={styles.packItem}>
                  <View style={styles.packHeader}>
                    <RadioButton value={pack.id} />
                    <View style={styles.packInfo}>
                      <Text style={styles.packName}>{pack.name}</Text>
                      <Text style={styles.packPrice}>{pack.price}</Text>
                    </View>
                  </View>
                  <View style={styles.packFeatures}>
                    {pack.features.map((feature, index) => (
                      <Text key={index} style={styles.feature}>
                        • {feature}
                      </Text>
                    ))}
                  </View>
                </View>
              ))}
            </RadioButton.Group>
          </Card.Content>
        </Card>

        <Button
          mode="contained"
          onPress={handleContinue}
          loading={loading}
          disabled={loading}
          style={styles.continueButton}
        >
          {t('onboarding.continue')}
        </Button>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    padding: spacing.lg,
  },
  header: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  title: {
    ...typography.h1,
    color: colors.primary,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  subtitle: {
    ...typography.body,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  card: {
    marginBottom: spacing.lg,
  },
  sectionTitle: {
    ...typography.h3,
    marginBottom: spacing.md,
  },
  radioItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
  },
  radioContent: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  radioTitle: {
    ...typography.subtitle,
    fontWeight: 'bold',
  },
  radioDescription: {
    ...typography.caption,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  divider: {
    marginVertical: spacing.lg,
  },
  packItem: {
    marginBottom: spacing.lg,
    padding: spacing.sm,
    borderRadius: 8,
    backgroundColor: colors.surface,
  },
  packHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  packInfo: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  packName: {
    ...typography.subtitle,
    fontWeight: 'bold',
  },
  packPrice: {
    ...typography.caption,
    color: colors.primary,
    fontWeight: 'bold',
  },
  packFeatures: {
    marginLeft: spacing.xl,
  },
  feature: {
    ...typography.caption,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  continueButton: {
    marginTop: spacing.xl,
    marginBottom: spacing.lg,
  },
});

export default OnboardingScreen;
