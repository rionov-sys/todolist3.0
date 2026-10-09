import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/task_repository.dart';
import 'data/services/api_service.dart';
import 'data/services/connectivity_service.dart';
import 'data/services/local_storage_service.dart';
import 'state/task_provider.dart';
import 'ui/screens/analytics_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/profile_screen.dart';
import 'ui/screens/timeline_screen.dart';
import 'ui/widgets/app_header.dart';
import 'ui/widgets/app_toast.dart';
import 'ui/widgets/bottom_nav_bar.dart';
import 'ui/widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final TaskRepository repository = TaskRepositoryImpl(
    api: ApiService(baseUrl: AppConfig.apiBaseUrl),
    storage: LocalStorageService(prefs),
  );
  runApp(
    ChangeNotifierProvider<TaskProvider>(
      create: (_) => TaskProvider(
        repository: repository,
        connectivity: ConnectivityService(),
      )..load(),
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
      home: const AppShell(),
    );
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

