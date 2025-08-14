// Hook de validation lean - seulement l'essentiel pour MVP
import { useState, useCallback } from 'react';

export interface ValidationError {
  [field: string]: string;
}

export const useSimpleValidation = () => {
  const [errors, setErrors] = useState<ValidationError>({});

  const validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  const validateRequired = (value: string): boolean => {
    return value.trim().length > 0;
  };

  const validateMinLength = (value: string, minLength: number): boolean => {
    return value.length >= minLength;
  };

  const validate = useCallback((fields: Record<string, any>, rules: Record<string, any>) => {
    const newErrors: ValidationError = {};

    Object.keys(rules).forEach(field => {
      const value = fields[field];
      const fieldRules = rules[field];

      if (fieldRules.required && !validateRequired(value)) {
        newErrors[field] = 'Ce champ est requis';
        return;
      }

      if (fieldRules.email && value && !validateEmail(value)) {
        newErrors[field] = 'Email invalide';
        return;
      }

      if (fieldRules.minLength && value && !validateMinLength(value, fieldRules.minLength)) {
        newErrors[field] = `Minimum ${fieldRules.minLength} caractères`;
        return;
      }
    });

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, []);

  const clearErrors = useCallback(() => {
    setErrors({});
  }, []);

  const clearError = useCallback((field: string) => {
    setErrors(prev => {
      const newErrors = { ...prev };
      delete newErrors[field];
      return newErrors;
    });
  }, []);

  return {
    errors,
    validate,
    clearErrors,
    clearError,
    validateEmail,
    validateRequired,
    validateMinLength,
  };
};

export default useSimpleValidation;