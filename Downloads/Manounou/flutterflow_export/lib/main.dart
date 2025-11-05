import 'dart:ui' show PlatformDispatcher;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'core/app_container.dart';
import 'core/routes/app_router.dart';
import 'core/services/auth_service.dart';
import 'core/services/children_service.dart';
import 'core/services/events_service.dart';
import 'core/services/schedules_service.dart';
import 'core/services/documents_service.dart';
import 'core/theme/famplan_colors.dart';
import 'pages/auth/login_page.dart';
import 'pages/dashboard/dashboard_page.dart';

void main() async {
  // Gestion globale des erreurs Flutter
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
    debugPrint('Stack: ${details.stack}');
  };
  
  // Gestion des erreurs non gérées (platform-level)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled Error: $error');
    debugPrint('Stack: $stack');
    return true; // Empêche le crash immédiat
  };
  
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Supabase avec gestion d'erreur
    try {
      await Supabase.initialize(
        url: 'https://emgrtgencepzainsknsb.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZ3J0Z2VuY2VwemFpbnNrbnNiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUxNjU3MzcsImV4cCI6MjA3MDc0MTczN30.2TtED_BEXHf6UqgPPcuOOd5YYTZlyqLSZRMoZtO93yM',
      );
      debugPrint('✅ Supabase initialisé avec succès');
    } catch (e, stack) {
      debugPrint('❌ Erreur initialisation Supabase: $e');
      debugPrint('Stack: $stack');
      // Continuer quand même pour voir si l'app peut démarrer sans Supabase
    }
    
    // Initialize Intl
    Intl.defaultLocale = 'fr_FR';
    
    runApp(const ManounouApp());
  } catch (e, stack) {
    debugPrint('❌ Erreur fatale dans main(): $e');
    debugPrint('Stack: $stack');
    // Afficher une erreur à l'utilisateur plutôt que de crasher
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Erreur au démarrage',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ManounouApp extends StatelessWidget {
  const ManounouApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ChildrenService()),
        ChangeNotifierProvider(create: (_) => EventsService()),
        ChangeNotifierProvider(create: (_) => SchedulesService()),
        ChangeNotifierProvider(create: (_) => DocumentsService()),
      ],
      child: Builder(
        builder: (context) {
          try {
            return MaterialApp.router(
              title: 'Manounou',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                fontFamily: 'SF Pro Display', // Sans-serif moderne
                colorScheme: ColorScheme.light(
                  primary: FamPlanColors.tealGreen,
                  secondary: FamPlanColors.orange,
                  tertiary: FamPlanColors.blue,
                  surface: FamPlanColors.backgroundWhite,
                  background: FamPlanColors.backgroundLight,
                  error: Colors.red,
                ),
                useMaterial3: true,
                cardTheme: CardThemeData(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                buttonTheme: ButtonThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: FamPlanColors.tealGreen,
                    foregroundColor: FamPlanColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                textTheme: const TextTheme(
                  headlineLarge: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.textDark,
                  ),
                  headlineMedium: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.textDark,
                  ),
                  titleLarge: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FamPlanColors.textDark,
                  ),
                  bodyLarge: TextStyle(
                    fontSize: 16,
                    color: FamPlanColors.textDark,
                  ),
                  bodyMedium: TextStyle(
                    fontSize: 14,
                    color: FamPlanColors.textLight,
                  ),
                ),
              ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'), // Français
          Locale('en', 'US'), // Anglais (fallback)
        ],
              locale: const Locale('fr', 'FR'),
              routerConfig: AppRouter.router,
            );
          } catch (e, stack) {
            debugPrint('❌ Erreur dans ManounouApp.build(): $e');
            debugPrint('Stack: $stack');
            return MaterialApp(
              home: Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Erreur au démarrage',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$e',
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            // Redémarrer l'app
                            runApp(const ManounouApp());
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

