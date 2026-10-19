import 'package:flutter/material.dart';

import '../l10n/app_localizations_context.dart';
import '../services/analytics_service.dart';

/// One persistent Settings control; registration owns its separate draft choice.
class AnalyticsConsentControl extends StatefulWidget {
  const AnalyticsConsentControl({super.key, required this.analytics});
  final AnalyticsService analytics;

  @override
  State<AnalyticsConsentControl> createState() =>
      _AnalyticsConsentControlState();
}

class _AnalyticsConsentControlState extends State<AnalyticsConsentControl> {
  bool _saving = false;
  bool _error = false;

  Future<void> _choose(bool allowed) async {
    setState(() {
      _saving = true;
      _error = false;
    });
    var saved = false;
    try {
      saved = await widget.analytics.chooseConsent(allowed);
    } catch (_) {
      // Settings remains usable when optional storage/platform work fails.
    }
    if (mounted) {
      setState(() {
        _saving = false;
        _error = !saved;
      });
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: widget.analytics,
        builder: (context, _) {
          if (!widget.analytics.loaded) return const SizedBox.shrink();
          return Card(
            key: const Key('analytics-settings-card'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTileTheme.merge(
                    titleAlignment: ListTileTitleAlignment.center,
                    child: SwitchListTile(
                      key: const Key('analytics-toggle'),
                      title: Text(context.l10n.analyticsTitle),
                      subtitle: Text(context.l10n.analyticsExplanation,
                          style: Theme.of(context).textTheme.bodySmall),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.trailing,
                      dense: true,
                      value: widget.analytics.consent == true,
                      onChanged:
                          _saving || !widget.analytics.loaded ? null : _choose,
                    ),
                  ),
                  if (_error)
                    Semantics(
                      liveRegion: true,
                      child: Text(context.l10n.analyticsSaveFailed,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                ],
              ),
            ),
          );
        },
      );
}
