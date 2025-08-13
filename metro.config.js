const { getDefaultConfig } = require('expo/metro-config');

const config = getDefaultConfig(__dirname);

// Configuration pour React Native Web
config.resolver.platforms = ['ios', 'android', 'native', 'web'];

// Configuration des extensions de fichiers
config.resolver.sourceExts.push('svg');

// Configuration pour les assets
config.resolver.assetExts = config.resolver.assetExts.filter(ext => ext !== 'svg');

// Configuration du transformer pour SVG
config.transformer.babelTransformerPath = require.resolve('react-native-svg-transformer');

// Configuration pour améliorer les performances
config.transformer.minifierConfig = {
  keep_fnames: true,
  mangle: {
    keep_fnames: true,
  },
};

// Configuration pour le cache
config.resetCache = true;

module.exports = config;