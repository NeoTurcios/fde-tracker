import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'data/api/forza_api_client.dart';
import 'data/repositories/history_repository.dart';
import 'data/repositories/query_points_repository.dart';
import 'data/services/rewarded_ad_service.dart';
import 'presentation/blocs/tracking_bloc.dart';
import 'presentation/blocs/theme_cubit.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/history/history_screen.dart';
import 'presentation/settings/settings_screen.dart';

class FDEApp extends StatefulWidget {
  final HistoryRepository historyRepository;
  final ThemeCubit themeCubit;
  final QueryPointsRepository queryPointsRepository;
  final RewardedAdService rewardedAdService;

  const FDEApp({
    super.key,
    required this.historyRepository,
    required this.themeCubit,
    required this.queryPointsRepository,
    required this.rewardedAdService,
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
        ChangeNotifierProvider.value(value: widget.queryPointsRepository),
        Provider.value(value: widget.rewardedAdService),
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
                      child: const Icon(PhosphorIconsFill.truck, color: AppTheme.primaryColor, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'FDE Tracker',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
                actions: [
                  Consumer<QueryPointsRepository>(
                    builder: (context, repo, _) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Badge(
                          label: Text('${repo.balance}'),
                          child: IconButton(
                            icon: const Icon(PhosphorIconsFill.coin),
                            tooltip: 'Consultas restantes',
                            onPressed: () => _goToSettings(),
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(isDark ? PhosphorIconsFill.sun : PhosphorIconsFill.moon),
                    onPressed: _toggleTheme,
                    tooltip: 'Alternar tema',
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsFill.gear),
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
                    icon: Icon(PhosphorIconsFill.magnifyingGlass),
                    selectedIcon: Icon(PhosphorIconsFill.magnifyingGlass),
                    label: 'Rastrear',
                  ),
                  NavigationDestination(
                    icon: Icon(PhosphorIconsFill.clock),
                    selectedIcon: Icon(PhosphorIconsFill.clock),
                    label: 'Historial',
                  ),
                  NavigationDestination(
                    icon: Icon(PhosphorIconsFill.gear),
                    selectedIcon: Icon(PhosphorIconsFill.gear),
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
