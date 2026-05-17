import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_sidebar.dart';
import '../core/constants/app_constants.dart';
import 'providers/auth_provider.dart';
import 'auth/pages/login_page.dart';
import 'dashboard/pages/dashboard_page.dart';
import 'patients/pages/patient_list_page.dart';
import 'queue/pages/queue_page.dart';
import 'doctors/pages/doctor_list_page.dart';
import 'medical_records/pages/medical_record_page.dart';
import 'pharmacy/pages/pharmacy_page.dart';
import 'finance/pages/finance_page.dart';
import 'consultation/pages/consultation_page.dart';
import 'reports/pages/reports_page.dart';
import 'settings/pages/settings_page.dart';
import 'chatbot/widgets/chatbot_widget.dart';

/// Provider GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardPage()),
          GoRoute(path: '/patients', builder: (_, __) => const PatientListPage()),
          GoRoute(path: '/queue', builder: (_, __) => const QueuePage()),
          GoRoute(path: '/doctors', builder: (_, __) => const DoctorListPage()),
          GoRoute(path: '/medical-records', builder: (_, __) => const MedicalRecordPage()),
          GoRoute(path: '/pharmacy', builder: (_, __) => const PharmacyPage()),
          GoRoute(path: '/finance', builder: (_, __) => const FinancePage()),
          GoRoute(path: '/consultation', builder: (_, __) => const ConsultationPage()),
          GoRoute(path: '/reports', builder: (_, __) => const ReportsPage()),
          GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
        ],
      ),
    ],
  );
});

/// Widget utama aplikasi
class JalanSehatApp extends ConsumerWidget {
  const JalanSehatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}

/// Shell layout dengan sidebar + chatbot overlay
class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AppSidebar(
                currentRoute: currentRoute,
                userRole: auth.user?.role ?? AppConstants.roleAdmin,
                userName: auth.user?.name ?? 'User',
                userEmail: auth.user?.email ?? '',
                onLogout: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
                onNavigate: (route) => context.go(route),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: child,
                ),
              ),
            ],
          ),
          // Chatbot Gemini AI overlay
          const ChatbotWidget(),
        ],
      ),
    );
  }
}
