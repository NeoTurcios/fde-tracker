import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
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

  void _showThemePicker(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final current = themeCubit.currentOption;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Tema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                const Divider(height: 1),
                _themeOption(ctx, themeCubit, current, ThemeModeOption.system, 'Sistema', 'Usar configuracion del dispositivo', PhosphorIconsFill.monitorPlay),
                _themeOption(ctx, themeCubit, current, ThemeModeOption.light, 'Claro', 'Tema claro permanente', PhosphorIconsFill.sun),
                _themeOption(ctx, themeCubit, current, ThemeModeOption.dark, 'Oscuro', 'Tema oscuro permanente', PhosphorIconsFill.moon),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption(BuildContext ctx, ThemeCubit themeCubit, ThemeModeOption current, ThemeModeOption value, String title, String subtitle, IconData icon) {
    final selected = current == value;
    return ListTile(
      leading: Icon(icon, color: selected ? AppTheme.primaryColor : null),
      title: Text(title, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(subtitle),
      trailing: selected ? const Icon(PhosphorIconsFill.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        themeCubit.setFromOption(value);
        Navigator.pop(ctx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final themeOption = themeCubit.currentOption;

    final themeLabel = themeOption == ThemeModeOption.system
        ? 'Sistema'
        : themeOption == ThemeModeOption.light
            ? 'Claro'
            : 'Oscuro';

    final themeIcon = themeOption == ThemeModeOption.system
        ? PhosphorIconsFill.monitorPlay
        : themeOption == ThemeModeOption.light
            ? PhosphorIconsFill.sun
            : PhosphorIconsFill.moon;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Apariencia'),
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(themeIcon, color: AppTheme.primaryColor),
            ),
            title: const Text('Tema'),
            subtitle: Text(themeLabel),
            trailing: const Icon(PhosphorIconsFill.caretRight),
            onTap: () => _showThemePicker(context),
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
                  child: const Icon(PhosphorIconsFill.globe, color: Colors.green),
                ),
                title: const Text('Pais predeterminado'),
                subtitle: Text(_selectedCountry.displayName),
                trailing: DropdownButton<Country>(
                  value: _selectedCountry,
                  underline: const SizedBox(),
                  items: Country.values.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c.displayName));
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
                  child: const Icon(PhosphorIconsFill.bell, color: AppTheme.infoColor),
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
                  child: const Icon(PhosphorIconsFill.arrowClockwise, color: AppTheme.warningColor),
                ),
                title: const Text('Actualizacion automatica'),
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
                  child: const Icon(PhosphorIconsFill.database, color: Colors.blue),
                ),
                title: const Text('Limite de historial'),
                subtitle: Text('Guardar las ultimas $_cacheLimit guias'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(PhosphorIconsFill.minusCircle, size: 20),
                      onPressed: _cacheLimit > AppConstants.minCacheLimit ? () {
                        setState(() => _cacheLimit -= 5);
                        _saveSettings();
                      } : null,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text('$_cacheLimit', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(PhosphorIconsFill.plusCircle, size: 20),
                      onPressed: _cacheLimit < AppConstants.maxCacheLimit ? () {
                        setState(() => _cacheLimit += 5);
                        _saveSettings();
                      } : null,
                    ),
                  ],
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
                  child: const Icon(PhosphorIconsFill.trash, color: Colors.red),
                ),
                title: const Text('Limpiar historial'),
                subtitle: const Text('Eliminar todas las guias guardadas'),
                onTap: () => _confirmClearHistory(context),
            trailing: const Icon(PhosphorIconsFill.caretRight),
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
                subtitle: Text('Version 1.0.0'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.info, color: AppTheme.primaryColor),
                ),
                title: const Text('App no oficial'),
                subtitle: const Text('Los datos pertenecen a Forza Delivery Express'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionHeader('Legal'),
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
                  child: const Icon(PhosphorIconsFill.shieldCheck, color: AppTheme.primaryColor),
                ),
                title: const Text('Licencia'),
                subtitle: const Text('Software propietario - Todos los derechos reservados'),
                trailing: const Icon(PhosphorIconsFill.caretRight),
                onTap: () => _showLicenseDialog(context),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.truck, color: Colors.orange),
                ),
                title: const Text('Fuente de datos'),
                subtitle: const Text('Forza Delivery Express (no afiliado)'),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(PhosphorIconsFill.code, color: Colors.blue),
                ),
                title: const Text('Licencias de terceros'),
                subtitle: const Text('Ver licencias de paquetes Flutter'),
                trailing: const Icon(PhosphorIconsFill.caretRight),
                onTap: () => _showThirdPartyLicenses(context),
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
        content: const Text('Eliminar todo el historial de guias guardadas?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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

  void _showLicenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Licencia de uso'),
        content: const SingleChildScrollView(
          child: Text(
            'FDE Tracker - Software propietario\n\n'
            'Copyright © 2024-2025 Solaris GT\n'
            'Todos los derechos reservados.\n\n'
            'Esta aplicación es de uso privado y no está '
            'autorizada su distribución, modificación, '
            'ingeniería inversa o uso comercial sin '
            'autorización expresa por escrito.\n\n'
            'Esta app no está afiliada, asociada ni '
            'respaldada por Forza Delivery Express. '
            'Los datos de rastreo pertenecen a sus '
            'respectivos propietarios.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showThirdPartyLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'FDE Tracker',
      applicationVersion: '1.0.0',
      applicationIcon: const CircleAvatar(
        backgroundColor: AppTheme.primaryColor,
        child: Text('FDE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}