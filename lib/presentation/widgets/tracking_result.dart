import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/models/tracking_response.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/models/tracking_history_entry.dart';
import '../blocs/tracking_bloc.dart';

class TrackingResultWidget extends StatelessWidget {
  final TrackingState state;

  const TrackingResultWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is TrackingLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Buscando información...'),
            ],
          ),
        ),
      );
    }

    if (state is TrackingError) {
      final error = state as TrackingError;
      return Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Center(
          child: Column(
            children: [
              Icon(PhosphorIconsFill.magnifyingGlassMinus, size: 64, color: AppTheme.errorColor.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                'No encontrado',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  error.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.read<TrackingBloc>().add(ClearTrackingEvent()),
                icon: const Icon(PhosphorIconsFill.arrowLeft),
                label: const Text('Intentar de nuevo'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is TrackingLoaded) {
      final loaded = state as TrackingLoaded;
      final payload = loaded.payload;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HistoryRepository>().add(TrackingHistoryEntry(
          guideSerie: loaded.guideSerie,
          guideNumber: loaded.guideNumber,
          statusTitle: payload.statusTrackingTitle,
          statusDescription: payload.statusTrackingDescription,
          receiverName: payload.receiverName,
          lastUpdate: payload.statusList.isNotEmpty
              ? payload.statusList.last.dateCreate
              : '',
        ));
      });

      return _buildTrackingInfo(context, loaded);
    }

    return const SizedBox.shrink();
  }

  Widget _buildTrackingInfo(BuildContext context, TrackingLoaded loaded) {
    final payload = loaded.payload;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(context, loaded),
          const SizedBox(height: 16),
          _buildInfoCards(context, loaded),
          const SizedBox(height: 16),
          _buildTimeline(context, payload.statusList),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, TrackingLoaded loaded) {
    final payload = loaded.payload;
    final statusColor = StatusColors.getColor(payload.statusTrackingTitle);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor.withValues(alpha: 0.25), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIconsFill.truck,
                    color: statusColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loaded.formattedGuide,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        payload.senderName,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payload.statusTrackingTitle,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                            fontSize: 15,
                          ),
                        ),
                        if (payload.statusTrackingDescription.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            payload.statusTrackingDescription,
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (payload.deliveryEta.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(PhosphorIconsFill.clock, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'ETA: ${payload.deliveryEta}',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, TrackingLoaded loaded) {
    final payload = loaded.payload;

    return Row(
      children: [
        Expanded(
          child: _infoCard(
            context,
            icon: PhosphorIconsFill.user,
            label: 'Remitente',
            value: payload.senderName,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _infoCard(
            context,
            icon: PhosphorIconsFill.userCircle,
            label: 'Destinatario',
            value: payload.receiverName,
          ),
        ),
      ],
    );
  }

  Widget _infoCard(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<TrackingStatus> statusList) {
    if (statusList.isEmpty) return const SizedBox.shrink();

    final reversed = statusList.reversed.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(PhosphorIconsFill.list, size: 18, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Historial de rastreo',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reversed.length,
              separatorBuilder: (context, index) => const SizedBox(height: 0),
              itemBuilder: (context, index) {
                return _timelineItem(context, reversed[index], index == 0, index == reversed.length - 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _timelineItem(BuildContext context, TrackingStatus status, bool isFirst, bool isLast) {
    final statusColor = StatusColors.getColor(status.label);
    final isActive = isFirst;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: isActive ? 16 : 12,
                  height: isActive ? 16 : 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: isActive ? statusColor : AppTheme.textSecondary.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: statusColor.withValues(alpha: 0.3), width: 3) : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppTheme.textSecondary.withValues(alpha: 0.15),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: isActive ? statusColor : null,
                      fontSize: 14,
                    ),
                  ),
                  if (status.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      status.description,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                  if (status.dateCreate.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(status.dateCreate),
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute';
    } catch (_) {
      return dateStr;
    }
  }
}