import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AchievementPresentationStore {
  Future<Set<String>> readPresentedIds(String userId);
  Future<void> markPresented(String userId, String achievementId);
}

class SecureAchievementPresentationStore
    implements AchievementPresentationStore {
  SecureAchievementPresentationStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<Set<String>> readPresentedIds(String userId) async {
    final value = await _storage.read(key: _keyFor(userId));
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return {};
      return decoded.whereType<String>().toSet();
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> markPresented(String userId, String achievementId) async {
    final ids = await readPresentedIds(userId);
    ids.add(achievementId);
    await _storage.write(key: _keyFor(userId), value: jsonEncode(ids.toList()));
  }

  String _keyFor(String userId) => 'lvt_presented_achievements_$userId';
}
