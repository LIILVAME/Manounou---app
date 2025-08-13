// Service de validation lean - Version MVP simplifiée
import { UserRole } from '../types';

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
}

// Validation email simple
export const validateEmail = (email: string): boolean => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

// Validation mot de passe MVP (simple)
export const validatePassword = (password: string): ValidationResult => {
  const errors: string[] = [];

  if (password.length < 6) {
    errors.push('Le mot de passe doit contenir au moins 6 caractères');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Validation nom/prénom
export const validateName = (name: string): boolean => {
  return name.trim().length >= 2;
};

// Validation téléphone simple
export const validatePhone = (phone: string): boolean => {
  const phoneRegex = /^[+]?[0-9\s-()]{8,15}$/;
  return phoneRegex.test(phone);
};

// Validation rôle utilisateur
export const validateUserRole = (role: string): role is UserRole => {
  return ['parent', 'nounou', 'admin'].includes(role);
};

// Validation date de naissance
export const validateBirthDate = (date: Date): boolean => {
  const now = new Date();
  const minAge = new Date(now.getFullYear() - 100, now.getMonth(), now.getDate());
  return date >= minAge && date <= now;
};

// Validation formulaire inscription MVP
export const validateSignUpForm = (data: {
  email: string;
  password: string;
  firstName: string;
  lastName: string;
  role: string;
}): ValidationResult => {
  const errors: string[] = [];

  if (!validateEmail(data.email)) {
    errors.push('Email invalide');
  }

  const passwordResult = validatePassword(data.password);
  if (!passwordResult.isValid) {
    errors.push(...passwordResult.errors);
  }

  if (!validateName(data.firstName)) {
    errors.push('Prénom requis (min 2 caractères)');
  }

  if (!validateName(data.lastName)) {
    errors.push('Nom requis (min 2 caractères)');
  }

  if (!validateUserRole(data.role)) {
    errors.push('Rôle invalide');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

// Validation formulaire enfant MVP
export const validateChildForm = (data: {
  firstName: string;
  lastName: string;
  birthDate: Date;
}): ValidationResult => {
  const errors: string[] = [];

  if (!validateName(data.firstName)) {
    errors.push('Prénom de l\'enfant requis');
  }

  if (!validateName(data.lastName)) {
    errors.push('Nom de l\'enfant requis');
  }

  if (!validateBirthDate(data.birthDate)) {
    errors.push('Date de naissance invalide');
  }

  return {
    isValid: errors.length === 0,
    errors,
  };
};

export default {
  validateEmail,
  validatePassword,
  validateName,
  validatePhone,
  validateUserRole,
  validateBirthDate,
  validateSignUpForm,
  validateChildForm,
};
