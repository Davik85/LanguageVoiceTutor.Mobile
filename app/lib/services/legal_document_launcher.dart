import 'package:flutter/services.dart';

abstract final class LegalDocuments {
  static final terms = Uri.parse('https://languagevoicetutor.com/terms.html');
  static final privacy =
      Uri.parse('https://languagevoicetutor.com/privacy.html');
  static bool permits(Uri uri) => uri == terms || uri == privacy;
}

abstract class LegalDocumentLauncher {
  Future<bool> open(Uri document);
}

/// Uses the app's existing Android platform-channel architecture. No WebView,
/// dependency or permission is needed to ask Android to open an HTTPS document.
class AndroidLegalDocumentLauncher implements LegalDocumentLauncher {
  const AndroidLegalDocumentLauncher({MethodChannel? channel})
      : _channel = channel ??
            const MethodChannel(
                'com.languagevoicetutor.mobile/legal_documents');
  final MethodChannel _channel;

  @override
  Future<bool> open(Uri document) async {
    if (!LegalDocuments.permits(document)) return false;
    try {
      return await _channel.invokeMethod<bool>(
              'openExternal', {'url': document.toString()}) ==
          true;
    } catch (_) {
      return false;
    }
  }
}
