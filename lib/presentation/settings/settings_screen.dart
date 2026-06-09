import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../blocs/theme_cubit.dart';
import '../../data/repositories/history_repository.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int _cacheLimit;
  bool _notificationsEnabled = true;
  bool _autoRefresh = false;
  int _refreshInterval = 30;
  Country _selectedCountry = Country.guatemala;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cacheLimit = prefs.getInt(AppConstants.prefsKeyCacheLimit) ?? AppConstants.defaultCacheLimit;
      _notificationsEnabled = prefs.getBool(AppConstants.prefsKeyNotificationsEnabled) ?? true;
      _autoRefresh = prefs.getBool(AppConstants.prefsKeyAutoRefresh) ?? false;
      _refreshInterval = prefs.getInt(AppConstants.prefsKeyRefreshInterval) ?? 30;
      final countryStr = prefs.getString(AppConstants.prefsKeyDefaultCountry) ?? 'guatemala';
      _selectedCountry = countryStr == 'honduras' ? Country.honduras : Country.guatemala;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefsKeyCacheLimit, _cacheLimit);
    await prefs.setBool(AppConstants.prefsKeyNotificationsEnabled, _notificationsEnabled);
    await prefs.setBool(AppConstants.prefsKeyAutoRefresh, _autoRefresh);
    await prefs.setInt(AppConstants.prefsKeyRefreshInterval, _refreshInterval);
    await prefs.setString(AppConstants.prefsKeyDefaultCountry, _selectedCountry.name);

    if (!mounted) return;
    final historyRepo = context.read<HistoryRepository>();
    await historyRepo.setLimit(_cacheLimit);
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.watch<ThemeCubit>();
    final themeOption = themeCubit.currentOption;

    return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionHeader('Apariencia'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.palette_rounded, color: AppTheme.primaryColor),
                    ),
                    title: const Text('Tema'),
                    subtitle: Text(themeOption.displayName),
                    trailing: SegmentedButton<ThemeModeOption>(
                      segments: ThemeModeOption.values.map((opt) {
                        return ButtonSegment(
                          value: opt,
                          label: Text(
                            opt == ThemeModeOption.system ? 'Auto' :
                            opt == ThemeModeOption.light ? 'Claro' : 'Oscuro',
                            style: const TextStyle(fontSize: 12),
                          ),
                          icon: Icon(
                            opt == ThemeModeOption.system ? Icons.brightness_auto_rounded :
                            opt == ThemeModeOption.light ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 16,
                          ),
                        );
                      }).toList(),
                      selected: {themeOption},
                      onSelectionChanged: (selected) {
                        final option = selected.first;
                        themeCubit.setFromOption(option);
                      },
                      showSelectedIcon: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Rastreo'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.public_rounded, color: Colors.green),
                    ),
                    title: const Text('País predeterminado'),
                    subtitle: Text('${_selectedCountry.flagEmoji} ${_selectedCountry.displayName}'),
                    trailing: DropdownButton<Country>(
                      value: _selectedCountry,
                      underline: const SizedBox(),
                      items: Country.values.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text('${c.flagEmoji} ${c.displayName}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedCountry = value);
                          _saveSettings();
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.infoColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.notifications_rounded, color: AppTheme.infoColor),
                    ),
                    title: const Text('Notificaciones'),
                    subtitle: const Text('Alertas de cambios de estado'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                      _saveSettings();
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  SwitchListTile(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.refresh_rounded, color: AppTheme.warningColor),
                    ),
                    title: const Text('Actualización automática'),
                    subtitle: const Text('Refrescar estado al abrir la app'),
                    value: _autoRefresh,
                    onChanged: (value) {
                      setState(() => _autoRefresh = value);
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Almacenamiento'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.storage_rounded, color: Colors.blue),
                    ),
                    title: const Text('Límite de historial'),
                    subtitle: Text('Guardar las últimas $_cacheLimit guías'),
                    trailing: SizedBox(
                      width: 120,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20),
                            onPressed: _cacheLimit > AppConstants.minCacheLimit
                                ? () {
                                    setState(() => _cacheLimit -= 5);
                                    _saveSettings();
                                  }
                                : null,
                          ),
                          Text('$_cacheLimit', style: const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20),
                            onPressed: _cacheLimit < AppConstants.maxCacheLimit
                                ? () {
                                    setState(() => _cacheLimit += 5);
                                    _saveSettings();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Colors.red),
                    ),
                    title: const Text('Limpiar historial'),
                    subtitle: const Text('Eliminar todas las guías guardadas'),
                    trailing: TextButton.icon(
                      onPressed: () => _confirmClearHistory(context),
                      icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                      label: const Text('Limpiar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Acerca de'),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text('FDE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('FDE Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Versión ${AppConstants.appVersion}'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor),
                    ),
                    title: const Text('App no oficial'),
                    subtitle: const Text('Los datos pertenecen a Forza Delivery Express'),
                    trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Eliminar todo el historial de guías guardadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryRepository>().clear();
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}