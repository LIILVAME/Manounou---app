import React, { useState } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import {
  Text,
  TextInput,
  Button,
  Card,
  Title,
  Paragraph,
  RadioButton,
} from 'react-native-paper';
import { useAuth } from '../../contexts/AuthContext';
import { colors, spacing, typography } from '../../constants/theme';

interface RegisterScreenProps {
  navigation: any;
}

const RegisterScreen: React.FC<RegisterScreenProps> = ({ navigation }) => {
  const [formData, setFormData] = useState({
    email: '',
    password: '',
    confirmPassword: '',
    firstName: '',
    lastName: '',
    phone: '',
    role: 'parent' as 'parent' | 'nounou',
  });
  const [loading, setLoading] = useState(false);
  const { signUp } = useAuth();

  const handleRegister = async () => {
    if (
      !formData.email ||
      !formData.password ||
      !formData.firstName ||
      !formData.lastName
    ) {
      Alert.alert('Erreur', 'Veuillez remplir tous les champs obligatoires');
      return;
    }

    if (formData.password !== formData.confirmPassword) {
      Alert.alert('Erreur', 'Les mots de passe ne correspondent pas');
      return;
    }

    if (formData.password.length < 6) {
      Alert.alert(
        'Erreur',
        'Le mot de passe doit contenir au moins 6 caractères'
      );
      return;
    }

    try {
      setLoading(true);
      await signUp(
        formData.email,
        formData.password,
        formData.firstName,
        formData.lastName,
        formData.role
      );
    } catch (error: any) {
      Alert.alert('Erreur', error.message || "Échec de l'inscription");
    } finally {
      setLoading(false);
    }
  };

  const updateFormData = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView contentContainerStyle={styles.scrollContainer}>
        <View style={styles.content}>
          <View style={styles.header}>
            <Title style={styles.title}>Créer un compte</Title>
            <Paragraph style={styles.subtitle}>
              Rejoignez la communauté Manounou
            </Paragraph>
          </View>

          <Card style={styles.card}>
            <Card.Content>
              <View style={styles.row}>
                <TextInput
                  label="Prénom *"
                  value={formData.firstName}
                  onChangeText={value => updateFormData('firstName', value)}
                  mode="outlined"
                  style={[styles.input, styles.halfInput]}
                />
                <TextInput
                  label="Nom *"
                  value={formData.lastName}
                  onChangeText={value => updateFormData('lastName', value)}
                  mode="outlined"
                  style={[styles.input, styles.halfInput]}
                />
              </View>

              <TextInput
                label="Email *"
                value={formData.email}
                onChangeText={value => updateFormData('email', value)}
                mode="outlined"
                keyboardType="email-address"
                autoCapitalize="none"
                style={styles.input}
              />

              <TextInput
                label="Téléphone"
                value={formData.phone}
                onChangeText={value => updateFormData('phone', value)}
                mode="outlined"
                keyboardType="phone-pad"
                style={styles.input}
              />

              <View style={styles.roleSection}>
                <Text style={styles.roleTitle}>Je suis :</Text>
                <RadioButton.Group
                  onValueChange={value => updateFormData('role', value)}
                  value={formData.role}
                >
                  <View style={styles.radioOption}>
                    <RadioButton value="parent" />
                    <Text style={styles.radioLabel}>Parent</Text>
                  </View>
                  <View style={styles.radioOption}>
                    <RadioButton value="nounou" />
                    <Text style={styles.radioLabel}>Nounou</Text>
                  </View>
                </RadioButton.Group>
              </View>

              <TextInput
                label="Mot de passe *"
                value={formData.password}
                onChangeText={value => updateFormData('password', value)}
                mode="outlined"
                secureTextEntry
                style={styles.input}
              />

              <TextInput
                label="Confirmer le mot de passe *"
                value={formData.confirmPassword}
                onChangeText={value => updateFormData('confirmPassword', value)}
                mode="outlined"
                secureTextEntry
                style={styles.input}
              />

              <Button
                mode="contained"
                onPress={handleRegister}
                loading={loading}
                disabled={loading}
                style={styles.button}
              >
                S'inscrire
              </Button>
            </Card.Content>
          </Card>

          <View style={styles.footer}>
            <Text style={styles.footerText}>Déjà un compte ?</Text>
            <Button
              mode="text"
              onPress={() => navigation.navigate('Login')}
              compact
            >
              Se connecter
            </Button>
          </View>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollContainer: {
    flexGrow: 1,
  },
  content: {
    flex: 1,
    padding: spacing.lg,
    justifyContent: 'center',
  },
  header: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  title: {
    ...typography.h1,
    color: colors.primary,
    marginBottom: spacing.sm,
  },
  subtitle: {
    ...typography.body,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  card: {
    marginBottom: spacing.lg,
  },
  row: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  input: {
    marginBottom: spacing.md,
  },
  halfInput: {
    flex: 0.48,
  },
  roleSection: {
    marginBottom: spacing.md,
  },
  roleTitle: {
    ...typography.h4,
    marginBottom: spacing.sm,
    color: colors.text,
  },
  radioOption: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  radioLabel: {
    marginLeft: spacing.sm,
    color: colors.text,
  },
  button: {
    marginTop: spacing.md,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
  },
  footerText: {
    color: colors.textSecondary,
  },
});

export default RegisterScreen;
