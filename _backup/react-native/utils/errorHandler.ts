/**
 * Utilitaires pour la gestion centralisée des erreurs
 */

export interface ErrorResult {
  message: string;
  code?: string;
  field?: string;
}

/**
 * Classe pour la gestion centralisée des erreurs
 */
export class ErrorHandler {
  private static errorMessages: Record<string, string> = {
    // Erreurs d'authentification
    'Invalid login credentials': 'Email ou mot de passe incorrect',
    'Email not confirmed': 'Veuillez confirmer votre email avant de vous connecter',
    'User already registered': 'Un compte existe déjà avec cet email',
    'Password should be at least 6 characters': 'Le mot de passe doit contenir au moins 6 caractères',
    'Invalid email': 'Format d\'email invalide',
    'Email rate limit exceeded': 'Trop de tentatives, veuillez réessayer plus tard',
    
    // Erreurs de base de données
    'duplicate key value violates unique constraint': 'Cette valeur existe déjà',
    'foreign key constraint': 'Référence invalide',
    'check constraint': 'Données invalides',
    
    // Erreurs réseau
    'Network request failed': 'Erreur de connexion, vérifiez votre réseau',
    'timeout': 'Délai d\'attente dépassé',
    
    // Erreurs génériques
    'Internal server error': 'Erreur serveur, veuillez réessayer',
    'Service unavailable': 'Service temporairement indisponible',
  };

  /**
   * Traduit une erreur technique en message utilisateur
   */
  static translateError(error: any): ErrorResult {
    if (!error) {
      return { message: 'Une erreur inconnue s\'est produite' };
    }

    // Si c'est déjà un string
    if (typeof error === 'string') {
      return { message: this.getTranslatedMessage(error) };
    }

    // Si c'est un objet avec message
    if (error.message) {
      return {
        message: this.getTranslatedMessage(error.message),
        code: error.code,
        field: error.field,
      };
    }

    // Si c'est une erreur Supabase
    if (error.error_description) {
      return { message: this.getTranslatedMessage(error.error_description) };
    }

    // Fallback
    return { message: 'Une erreur inattendue s\'est produite' };
  }

  /**
   * Récupère le message traduit ou retourne le message original
   */
  private static getTranslatedMessage(message: string): string {
    // Recherche exacte
    if (this.errorMessages[message]) {
      return this.errorMessages[message];
    }

    // Recherche partielle
    for (const [key, value] of Object.entries(this.errorMessages)) {
      if (message.toLowerCase().includes(key.toLowerCase())) {
        return value;
      }
    }

    return message;
  }

  /**
   * Log une erreur de manière structurée
   */
  static logError(error: any, context?: string): void {
    const errorInfo = this.translateError(error);
    
    console.error('🚨 Erreur capturée:', {
      context: context || 'Unknown',
      message: errorInfo.message,
      code: errorInfo.code,
      field: errorInfo.field,
      originalError: error,
      timestamp: new Date().toISOString(),
    });
  }

  /**
   * Crée une erreur formatée pour l'interface utilisateur
   */
  static createUserError(message: string, field?: string): ErrorResult {
    return {
      message,
      field,
    };
  }

  /**
   * Vérifie si une erreur est liée au réseau
   */
  static isNetworkError(error: any): boolean {
    if (!error) return false;
    
    const message = error.message || error.toString();
    return (
      message.includes('Network') ||
      message.includes('timeout') ||
      message.includes('connection') ||
      message.includes('offline')
    );
  }

  /**
   * Vérifie si une erreur est liée à l'authentification
   */
  static isAuthError(error: any): boolean {
    if (!error) return false;
    
    const message = error.message || error.toString();
    return (
      message.includes('credentials') ||
      message.includes('unauthorized') ||
      message.includes('token') ||
      message.includes('session')
    );
  }

  /**
   * Ajoute un nouveau mapping d'erreur
   */
  static addErrorMapping(originalMessage: string, translatedMessage: string): void {
    this.errorMessages[originalMessage] = translatedMessage;
  }
}

export default ErrorHandler;