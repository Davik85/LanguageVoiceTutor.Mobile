import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations_context.dart';
import '../services/legal_document_launcher.dart';

/// Informational account-creation notice with independently actionable links.
class RegistrationLegalNotice extends StatefulWidget {
  const RegistrationLegalNotice({
    super.key,
    required this.onOpenDocument,
  });

  final ValueChanged<Uri> onOpenDocument;

  @override
  State<RegistrationLegalNotice> createState() =>
      _RegistrationLegalNoticeState();
}

class _RegistrationLegalNoticeState extends State<RegistrationLegalNotice> {
  static const _termsMarker = '{terms_link}';
  static const _privacyMarker = '{privacy_link}';
  final _termsTap = TapGestureRecognizer();
  final _privacyTap = TapGestureRecognizer();

  @override
  void initState() {
    super.initState();
    _termsTap.onTap = () => widget.onOpenDocument(LegalDocuments.terms);
    _privacyTap.onTap = () => widget.onOpenDocument(LegalDocuments.privacy);
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final template = l10n.registrationLegalNotice(_termsMarker, _privacyMarker);
    final spans = <InlineSpan>[];
    var offset = 0;
    for (final match
        in RegExp(r'\{terms_link\}|\{privacy_link\}').allMatches(template)) {
      if (match.start > offset) {
        spans.add(TextSpan(text: template.substring(offset, match.start)));
      }
      final terms = match.group(0) == _termsMarker;
      spans.add(TextSpan(
        text: terms ? l10n.termsOfService : l10n.privacyPolicy,
        style: const TextStyle(decoration: TextDecoration.underline),
        recognizer: terms ? _termsTap : _privacyTap,
        mouseCursor: SystemMouseCursors.click,
      ));
      offset = match.end;
    }
    if (offset < template.length) {
      spans.add(TextSpan(text: template.substring(offset)));
    }

    return Text.rich(
      TextSpan(children: spans),
      key: const Key('registration-legal-sentence'),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
