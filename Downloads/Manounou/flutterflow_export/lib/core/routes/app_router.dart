import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../pages/auth/login_page.dart';
import '../../pages/auth/register_page.dart';
import '../../pages/auth/onboarding_page.dart';
import '../../pages/dashboard/dashboard_page.dart';
import '../../pages/children/children_list_page.dart';
import '../../pages/children/child_form_page.dart';
import '../../pages/children/child_detail_page.dart';
import '../../pages/events/events_page.dart';
import '../../pages/events/event_form_page.dart';
import '../../pages/events/event_detail_page.dart';
import '../../pages/schedules/schedule_type_page.dart';
import '../../pages/schedules/schedule_input_page.dart';
import '../../pages/schedules/schedule_summary_page.dart';
import '../../pages/documents/documents_page.dart';
import '../../pages/documents/document_upload_page.dart';
import '../../pages/documents/document_detail_page.dart';
import '../../pages/profile/profile_page.dart';
import '../../core/services/children_service.dart';
import 'main_navigation.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      try {
        // Vérifier si Supabase est initialisé
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggedIn = session != null;
        final isOnLoginPage = state.matchedLocation == '/login' || 
                             state.matchedLocation == '/register';
        
        // Si pas connecté et pas sur page auth, rediriger vers login
        if (!isLoggedIn && !isOnLoginPage) {
          return '/login';
        }
        
        // Si connecté et sur page auth, rediriger vers dashboard
        if (isLoggedIn && isOnLoginPage) {
          return '/dashboard';
        }
        
        return null;
      } catch (e) {
        // Si erreur (Supabase non initialisé), rediriger vers login
        debugPrint('❌ Erreur dans router redirect: $e');
        return '/login';
      }
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const MainNavigationWrapper(
          currentIndex: 0,
          child: DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/children',
        builder: (context, state) => const MainNavigationWrapper(
          currentIndex: 1,
          child: ChildrenListPage(),
        ),
      ),
      GoRoute(
        path: '/children/new',
        builder: (context, state) => const ChildFormPage(),
      ),
      GoRoute(
        path: '/children/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChildDetailPage(childId: id);
        },
      ),
      GoRoute(
        path: '/children/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChildFormPage(childId: id);
        },
      ),
      GoRoute(
        path: '/events',
        builder: (context, state) => const MainNavigationWrapper(
          currentIndex: 2,
          child: EventsPage(),
        ),
      ),
      GoRoute(
        path: '/events/new',
        builder: (context, state) => const EventFormPage(),
      ),
      GoRoute(
        path: '/events/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventDetailPage(eventId: id);
        },
      ),
      GoRoute(
        path: '/events/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EventFormPage(eventId: id);
        },
      ),
      // Routes Schedules
      GoRoute(
        path: '/children/:childId/schedules/type',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final childrenService = context.read<ChildrenService>();
          final child = childrenService.children.firstWhere(
            (c) => c.id == childId,
            orElse: () => childrenService.children.first,
          );
          return ScheduleTypePage(
            childId: childId,
            childName: child.firstName,
          );
        },
      ),
      GoRoute(
        path: '/children/:childId/schedules/input',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final type = state.uri.queryParameters['type'];
          return ScheduleInputPage(
            childId: childId,
            scheduleType: type,
          );
        },
      ),
      GoRoute(
        path: '/children/:childId/schedules/summary',
        builder: (context, state) {
          final childId = state.pathParameters['childId']!;
          final scheduleId = state.uri.queryParameters['scheduleId'] ?? '';
          return ScheduleSummaryPage(
            childId: childId,
            scheduleId: scheduleId,
          );
        },
      ),
      GoRoute(
        path: '/documents',
        builder: (context, state) => const MainNavigationWrapper(
          currentIndex: 3,
          child: DocumentsPage(),
        ),
      ),
      GoRoute(
        path: '/documents/upload',
        builder: (context, state) => const DocumentUploadPage(),
      ),
      GoRoute(
        path: '/documents/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DocumentDetailPage(documentId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const MainNavigationWrapper(
          currentIndex: 4,
          child: ProfilePage(),
        ),
      ),
    ],
  );
}

