import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  ReactNode,
} from 'react';
// import AsyncStorage from '@react-native-async-storage/async-storage';
// import {getLocales} from 'react-native-localize';
import { Language, I18nState } from '../types';
import { translations } from '../constants/translations';

interface I18nContextType extends I18nState {
  setLanguage: (language: Language) => Promise<void>;
  changeLanguage: (language: Language) => Promise<void>;
  t: (key: string, params?: Record<string, string>) => string;
  language: Language;
}

const I18nContext = createContext<I18nContextType | undefined>(undefined);

const getDeviceLanguage = (): Language => {
  // const locales = getLocales();
  // const deviceLanguage = locales[0]?.languageCode;
  // return deviceLanguage === 'fr' ? 'fr' : 'en';
  return 'fr'; // Default to French for now
};

export const I18nProvider: React.FC<{ children: ReactNode }> = ({
  children,
}: {
  children: ReactNode;
}) => {
  const [language, setCurrentLanguage] = useState<Language>('fr');
  const [currentTranslations, setCurrentTranslations] = useState(
    translations.fr
  );

  useEffect(() => {
    loadLanguage();
  }, []);

  const loadLanguage = async (): Promise<void> => {
    try {
      // const savedLanguage = await AsyncStorage.getItem('language');
      // const lang = (savedLanguage as Language) || getDeviceLanguage();
      const lang = getDeviceLanguage();
      setCurrentLanguage(lang);
      setCurrentTranslations(translations[lang]);
    } catch (error) {
      // console.error('Failed to load language:', error);
    }
  };

  const setLanguage = async (newLanguage: Language): Promise<void> => {
    try {
      // await AsyncStorage.setItem('language', newLanguage);
      setCurrentLanguage(newLanguage);
      setCurrentTranslations(translations[newLanguage]);
    } catch (error) {
      // console.error('Failed to save language:', error);
    }
  };

  const t = (key: string, params?: Record<string, string>): string => {
    let translation =
      (currentTranslations as Record<string, string>)[key] || key;

    if (params) {
      Object.keys(params).forEach(param => {
        translation = translation.replace(`{{${param}}}`, params[param]);
      });
    }

    return translation;
  };

  const value: I18nContextType = {
    language,
    translations: currentTranslations,
    setLanguage,
    changeLanguage: setLanguage,
    t,
  };

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
};

export const useI18n = (): I18nContextType => {
  const context = useContext(I18nContext);
  if (!context) {
    throw new Error('useI18n must be used within an I18nProvider');
  }
  return context;
};
