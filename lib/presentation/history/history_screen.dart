import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../data/repositories/history_repository.dart';
import '../blocs/tracking_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyRepo = context.watch<HistoryRepository>();
    final history = historyRepo.all;

    return history.isEmpty
        ? _buildEmpty(context)
        : _buildHistoryList(context, historyRepo, history);
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(PhosphorIconsFill.clock, size: 80,
              color: AppTheme.textSecondary.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Sin historial',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Los envíos que rastrees aparecerán aquí',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    HistoryRepository historyRepo,
    List list,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(PhosphorIconsFill.clock, size: 20, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Historial',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '${list.length} guías',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(PhosphorIconsFill.trash, size: 20),
                onPressed: list.isEmpty
                    ? null
                    : () => _confirmClear(context, historyRepo),
                tooltip: 'Limpiar historial',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: list.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final entry = list[index];
              final statusColor = entry.hasError
                  ? AppTheme.errorColor
                  : StatusColors.getColor(entry.statusTitle);

              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    entry.hasError ? PhosphorIconsFill.warningCircle : PhosphorIconsFill.truck,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                title: Text(
                  entry.formattedGuide,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    fontFamily: 'monospace',
                  ),
                ),
                subtitle: Text(
                  entry.statusTitle.isNotEmpty
                      ? entry.statusTitle
                      : entry.receiverName.isNotEmpty
                          ? entry.receiverName
                          : 'Sin información',
                  style: TextStyle(
                    color: entry.statusTitle.isNotEmpty ? statusColor : AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(PhosphorIconsFill.x, size: 18),
                  onPressed: () =>
                      historyRepo.remove(entry.guideSerie, entry.guideNumber),
                ),
                onTap: () {
                  context.read<TrackingBloc>().add(
                    TrackPackageEvent(
                      entry.formattedGuide,
                      baseUrl: AppConstants.defaultBaseUrl,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _confirmClear(BuildContext context, HistoryRepository repo) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpiar historial'),
        content: const Text('¿Eliminar todo el historial de guías?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              repo.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Limpiar', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}