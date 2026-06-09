import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/api/forza_api_client.dart';
import 'data/repositories/history_repository.dart';
import 'presentation/blocs/tracking_bloc.dart';
import 'presentation/blocs/theme_cubit.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/settings/settings_screen.dart';

class FDEApp extends StatefulWidget {
  final HistoryRepository historyRepository;
  final ThemeCubit themeCubit;

  const FDEApp({
    super.key,
    required this.historyRepository,
    required this.themeCubit,
  });

  @override
  State<FDEApp> createState() => _FDEAppState();
}

class _FDEAppState extends State<FDEApp> {
  int _currentIndex = 0;

  void _goToSettings() {
    setState(() => _currentIndex = 2);
  }

  void _toggleTheme() {
    widget.themeCubit.toggleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => TrackingBloc(apiClient: ForzaApiClient())),
        ChangeNotifierProvider.value(value: widget.themeCubit),
        ChangeNotifierProvider.value(value: widget.historyRepository),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: widget.themeCubit,
        builder: (context, themeMode, _) {
          final isDark = themeMode == ThemeMode.dark;

          return MaterialApp(
            title: 'FDE Tracker',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: Scaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.local_shipping_rounded, color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'FDE Tracker',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
                    onPressed: _toggleTheme,
                    tooltip: 'Alternar tema',
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_rounded),
                    onPressed: _goToSettings,
                    tooltip: 'Ajustes',
                  ),
                ],
              ),
              body: IndexedStack(
                index: _currentIndex,
                children: const [
                  HomeScreen(),
                  HistoryScreen(),
                  SettingsScreen(),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.search_rounded),
                    selectedIcon: Icon(Icons.search_rounded),
                    label: 'Rastrear',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.history_rounded),
                    selectedIcon: Icon(Icons.history_rounded),
                    label: 'Historial',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_rounded),
                    selectedIcon: Icon(Icons.settings_rounded),
                    label: 'Ajustes',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}