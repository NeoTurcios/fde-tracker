import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/repositories/history_repository.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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

    _focusNode.unfocus();
    context.read<TrackingBloc>().add(TrackPackageEvent(text));
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
          Icon(Icons.local_shipping_rounded, size: 80, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
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
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _controller.text.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            _controller.clear();
                            _onTextChanged('');
                            context.read<TrackingBloc>().add(ClearTrackingEvent());
                          },
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Icons.paste_rounded, size: 20),
                      onPressed: _pasteFromClipboard,
                      tooltip: 'Pegar',
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isValid ? _track : null,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Rastrear'),
            ),
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
              Icon(Icons.history_rounded, size: 18, color: AppTheme.textSecondary),
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
                avatar: Icon(Icons.local_shipping_rounded, size: 16,
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