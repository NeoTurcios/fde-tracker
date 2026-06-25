import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/query_points_repository.dart';
import '../../data/services/rewarded_ad_service.dart';
import '../blocs/tracking_bloc.dart';
import '../widgets/tracking_result.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isValid = false;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    setState(() {
      _isValid = GuideParser.isValid(value);
    });
  }

  void _track() {
    final text = _controller.text.trim();
    if (!_isValid) return;

    final pointsRepo = context.read<QueryPointsRepository>();

    if (pointsRepo.queryCooldownRemaining > 0) {
      _startCooldownTimer();
      return;
    }

    if (!pointsRepo.canAffordTrack) {
      _showAdRequiredSheet();
      return;
    }

    _focusNode.unfocus();
    pointsRepo.deduct();
    pointsRepo.markQuery();
    _startCooldownTimer();
    context.read<TrackingBloc>().add(TrackPackageEvent(text));
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final repo = context.read<QueryPointsRepository>();
      if (repo.queryCooldownRemaining <= 0) {
        _cooldownTimer?.cancel();
      }
      setState(() {});
    });
  }

  void _showAdRequiredSheet() {
    final adService = context.read<RewardedAdService>();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        String statusMessage = '';
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final pointsRepo = context.read<QueryPointsRepository>();
            final canWatch = pointsRepo.canWatchAd;
            final remaining = pointsRepo.remainingDailyAds;
            final adCooldown = pointsRepo.adCooldownRemaining;

            void loadAndShowAd() {
              setSheetState(() {
                isLoading = true;
                statusMessage = 'Cargando anuncio...';
              });

              adService.loadAd(
                primaryAdUnitId: AppConstants.adMobRewardedInterstitialId,
                fallbackAdUnitId: AppConstants.adMobRewardedVideoId,
                onStatus: (status) {
                  if (!context.mounted) return;
                  switch (status) {
                    case RewardedAdStatus.loading:
                      setSheetState(() {
                        isLoading = true;
                        statusMessage = 'Cargando anuncio...';
                      });
                    case RewardedAdStatus.ready:
                      setSheetState(() {
                        statusMessage = 'Mostrando anuncio...';
                      });
                      adService.showAd(
                        onStatus: (showStatus) {
                          if (!context.mounted) return;
                          switch (showStatus) {
                            case RewardedAdStatus.rewarded:
                              final repo = context.read<QueryPointsRepository>();
                              repo.markAdWatched();
                              repo.add(AppConstants.pointsPerAd);
                              Navigator.pop(ctx);
                              _track();
                            case RewardedAdStatus.dismissed:
                              setSheetState(() {
                                isLoading = false;
                                statusMessage = 'Debes ver el anuncio completo para obtener consultas.';
                              });
                            case RewardedAdStatus.failed:
                              setSheetState(() {
                                isLoading = false;
                                statusMessage = 'Error al mostrar el anuncio. Intenta de nuevo.';
                              });
                            default:
                              break;
                          }
                        },
                      );
                    case RewardedAdStatus.failed:
                      setSheetState(() {
                        isLoading = false;
                        statusMessage = 'No hay anuncios disponibles. Intenta más tarde.';
                      });
                    default:
                      break;
                  }
                },
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: remaining > 0
                            ? AppTheme.warningColor.withValues(alpha: 0.1)
                            : AppTheme.errorColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        remaining > 0 ? PhosphorIconsFill.coin : PhosphorIconsFill.xCircle,
                        size: 40,
                        color: remaining > 0 ? AppTheme.warningColor : AppTheme.errorColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      remaining > 0 ? 'Sin consultas disponibles' : 'Límite diario alcanzado',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      remaining > 0
                          ? 'Mira un anuncio y obtén ${AppConstants.pointsPerAd} consultas adicionales.'
                          : 'Has visto $remaining anuncios hoy. Vuelve mañana para más consultas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Anuncios hoy: $remaining/${AppConstants.maxDailyAds}',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    if (adCooldown > 0 && remaining > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Espera $adCooldown s para ver otro anuncio',
                        style: const TextStyle(color: AppTheme.warningColor, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (statusMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          statusMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: statusMessage.contains('Debes') || statusMessage.contains('Error') || statusMessage.contains('No hay')
                                ? AppTheme.errorColor
                                : AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    if (remaining > 0)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: isLoading || !canWatch ? null : loadAndShowAd,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(PhosphorIconsFill.play),
                          label: Text(
                            !canWatch && adCooldown > 0
                                ? 'Espera $adCooldown s'
                                : isLoading
                                    ? 'Cargando...'
                                    : 'Ver anuncio',
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.pop(ctx),
                      child: const Text('Cancelar'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _controller.text = data!.text!.trim();
      _onTextChanged(_controller.text);
      _track();
    }
  }

  void _loadFromHistory(String guide) {
    _controller.text = guide;
    _onTextChanged(guide);
    _track();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        if (state is TrackingLoading || state is TrackingLoaded || state is TrackingError) {
          return _buildWithResult(context, state);
        }
        return _buildInitial(context);
      },
    );
  }

  Widget _buildInitial(BuildContext context) {
    final historyRepo = context.read<HistoryRepository>();
      return _buildBody(
      context,
      Column(
        children: [
          const SizedBox(height: 60),
          Icon(PhosphorIconsFill.truck, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            'Rastrea tu envío',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa el número de guía para conocer su estado',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildSearchField(context),
          const SizedBox(height: 16),
          _buildHistoryChips(context, historyRepo),
        ],
      ),
    );
  }

  Widget _buildWithResult(BuildContext context, TrackingState state) {
    return _buildBody(
      context,
      SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildSearchField(context),
            ),
            TrackingResultWidget(state: state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Widget body) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: body,
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            onSubmitted: _isValid ? (_) => _track() : null,
            textInputAction: TextInputAction.search,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(fontSize: 16, letterSpacing: 1),
              decoration: InputDecoration(
                hintText: 'Ej: FD34557216',
                prefixIcon: const Icon(PhosphorIconsFill.magnifyingGlass),
              suffixIcon: _controller.text.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(PhosphorIconsFill.x, size: 20),
                          onPressed: () {
                            _controller.clear();
                            _onTextChanged('');
                            context.read<TrackingBloc>().add(ClearTrackingEvent());
                          },
                        ),
                      ],
                    )
                    : IconButton(
                      icon: const Icon(PhosphorIconsFill.clipboardText, size: 20),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Pegar',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          Consumer<QueryPointsRepository>(
            builder: (context, repo, _) {
              final cooldown = repo.queryCooldownRemaining;
              final canPress = _isValid && cooldown <= 0;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: canPress ? _track : null,
                  icon: const Icon(PhosphorIconsFill.magnifyingGlass),
                  label: Text(
                    cooldown > 0 ? 'Esperar $cooldown s' : 'Rastrear',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryChips(BuildContext context, HistoryRepository historyRepo) {
    final history = historyRepo.all;
    if (history.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsFill.clock, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Recientes',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: history.take(10).map((entry) {
              return ActionChip(
                avatar: Icon(PhosphorIconsFill.truck, size: 16,
                    color: entry.hasError ? AppTheme.errorColor : AppTheme.primaryColor),
                label: Text(entry.formattedGuide, style: const TextStyle(fontSize: 13)),
                onPressed: () => _loadFromHistory(entry.formattedGuide),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
