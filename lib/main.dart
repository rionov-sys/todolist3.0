import 'package:flutter/material.dart' show BuildContext, Column, Expanded, IndexedStack, MaterialApp, SafeArea, Scaffold, State, StatefulWidget, StatelessWidget, Widget, WidgetsFlutterBinding, runApp;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/supabase_auth_service.dart';
import 'data/services/supabase_remote.dart';
import 'state/auth_provider.dart';
import 'state/task_provider.dart';
import 'ui/screens/analytics_screen.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/timeline_screen.dart';
import 'ui/widgets/app_header.dart';
import 'ui/widgets/app_toast.dart';
import 'ui/widgets/bottom_nav_bar.dart';
import 'ui/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cloud mode is opt-in via --dart-define so the repo stays secret-free.
  // With no defines the app boots local-only and still builds/runs.
  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
    );
  }

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SupabaseClient? client =
      AppConfig.hasSupabaseConfig ? Supabase.instance.client : null;

  final TaskRepository repository = TaskRepositoryImpl(
    api: client != null
        ? SupabaseRemote(client)
        : ApiService(baseUrl: AppConfig.apiBaseUrl),
    storage: LocalStorageService(prefs),
  );

  final TaskProvider taskProvider = TaskProvider(
    repository: repository,
    connectivity: ConnectivityService(),
  );
  final AuthProvider authProvider = AuthProvider(
    service: client != null
        ? SupabaseAuthService(client)
        : LocalAuthService(prefs),
    onSessionChanged: (bool loggedIn) {
      if (loggedIn) {
        taskProvider.load();
      } else {
        taskProvider.clear();
      }
    },
  )..bootstrap();

  runApp(
    MultiProvider(
      providers: <ChangeNotifierProvider<dynamic>>[
        ChangeNotifierProvider<TaskProvider>.value(value: taskProvider),
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const KeepGrindingApp(),
    ),
  );
}

/// Root widget: theme, navigation shell and global offline handling.
class KeepGrindingApp extends StatelessWidget {
  const KeepGrindingApp({super.key});

  // Backwards-compatible alias for existing tests / entry points.
  const factory KeepGrindingApp.myApp() = KeepGrindingApp;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthGate(),
    );
  }
}

/// Shows login until a session exists, then the main bottom-nav shell.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const LoginScreen();
    return const AppShell();
  }
}

/// Backwards-compatible alias so `MyApp` references keep working.
typedef MyApp = KeepGrindingApp;

/// Bottom-nav shell wiring the four main screens with a shared header.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<String> _subtitles = <String>[
    'Ringkasan Harian',
    'Jadwal & Timeline',
    'Statistik & Progres',
    'Profil & Pengaturan',
  ];

  void _go(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final TaskProvider provider = context.watch<TaskProvider>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            AppHeader(
              subtitle: _subtitles[_index],
              onNotifications: () => AppSnack.show(
                context,
                provider.isOffline
                    ? 'Kamu sedang offline — notifikasi disusun lokal.'
                    : 'Semua notifikasi sudah dibaca. 🎉',
              ),
              onOpenProfile: () => _go(3),
            ),
            if (provider.isOffline || provider.pendingSyncCount > 0)
              OfflineBanner(
                message: provider.notice ??
                    (provider.pendingSyncCount > 0
                        ? '${provider.pendingSyncCount} perubahan menunggu sinkron otomatis.'
                        : null),
              ),
            Expanded(
              child: IndexedStack(
                index: _index,
                children: <Widget>[
                  HomeScreen(onOpenTimeline: () => _go(1)),
                  TimelineScreen(onBack: () => _go(0)),
                  const AnalyticsScreen(),
                  const ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _index,
        onChanged: _go,
      ),
    );
  }
}

