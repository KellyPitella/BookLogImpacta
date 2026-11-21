import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class FavoriteService {
  static Future<void>? _pending;

  final AuthService _authService = AuthService();
  final ValueNotifier<Set<int>> _favoriteBookIds = ValueNotifier(
    Set<int>.unmodifiable(<int>{}),
  );

  ValueListenable<Set<int>> get favoriteBookIds => _favoriteBookIds;

  Future<bool> isFavorite(int bookId) async {
    return (await getFavoriteBookIds()).contains(bookId);
  }

  Future<Set<int>> getFavoriteBookIds() {
    return _enqueue(() async {
      final prefs = await SharedPreferences.getInstance();
      final key = await _userKey();
      final ids = _readIds(prefs, key);
      _publish(ids);
      return Set<int>.of(ids);
    });
  }

  Future<void> toggleFavorite(int bookId) {
    return _enqueue(() async {
      final prefs = await SharedPreferences.getInstance();
      final key = await _userKey();
      final ids = _readIds(prefs, key);
      if (!ids.add(bookId)) {
        ids.remove(bookId);
      }

      try {
        final saved = await prefs.setStringList(
          key,
          ids.map((id) => id.toString()).toList(),
        );
        if (!saved) {
          throw StateError('Não foi possível salvar os favoritos.');
        }
      } catch (_) {
        // SharedPreferences updates its cache before the platform write.
        await prefs.reload();
        rethrow;
      }
      _publish(ids);
    });
  }

  Future<String> _userKey() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      throw StateError(
        'É necessário estar autenticado para acessar favoritos.',
      );
    }
    return 'favorite_book_ids_${user.id}';
  }

  Set<int> _readIds(SharedPreferences prefs, String key) {
    return (prefs.getStringList(key) ?? <String>[]).map(int.parse).toSet();
  }

  void _publish(Set<int> ids) {
    if (!setEquals(_favoriteBookIds.value, ids)) {
      _favoriteBookIds.value = Set<int>.unmodifiable(ids);
    }
  }

  static Future<T> _enqueue<T>(Future<T> Function() operation) {
    final previous = _pending;
    final result = previous == null
        ? Future<T>.sync(operation)
        : previous.then((_) => operation());
    late final Future<void> barrier;
    void clearQueue() {
      if (identical(_pending, barrier)) _pending = null;
    }

    barrier = result.then<void>(
      (_) => clearQueue(),
      onError: (Object error, StackTrace stack) => clearQueue(),
    );
    _pending = barrier;
    return result;
  }
}
