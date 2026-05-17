import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:window_manager/window_manager.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'presentation/app.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup window untuk desktop
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: Size(AppConstants.defaultWindowWidth, AppConstants.defaultWindowHeight),
    minimumSize: Size(AppConstants.minWindowWidth, AppConstants.minWindowHeight),
    center: true,
    title: '${AppConstants.appName} - ${AppConstants.clinicName}',
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: _AppBootstrap()));
}

/// Bootstrap widget untuk cek autentikasi saat startup
class _AppBootstrap extends ConsumerStatefulWidget {
  const _AppBootstrap();

  @override
  ConsumerState<_AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends ConsumerState<_AppBootstrap> {
  @override
  void initState() {
    super.initState();
    // Cek status auth saat app dimulai
    Future.microtask(() {
      ref.read(authProvider.notifier).checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const JalanSehatApp();
  }
}
