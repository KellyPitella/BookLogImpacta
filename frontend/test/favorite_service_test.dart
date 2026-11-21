import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/favorite_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

String userJson(int id) =>
    jsonEncode({'id': id, 'nome': 'Leitor', 'email': 'reader@example.com'});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({'auth_user': userJson(1)});
  });

  test(
    'loads persisted favorites and publishes an immutable snapshot',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_user': userJson(1),
        'favorite_book_ids_1': ['3', '7', '3'],
      });
      final service = FavoriteService();
      var notifications = 0;
      service.favoriteBookIds.addListener(() => notifications++);

      final ids = await service.getFavoriteBookIds();
      expect(ids, {3, 7});
      expect(service.favoriteBookIds.value, {3, 7});
      expect(notifications, 1);
      ids.clear();
      expect(service.favoriteBookIds.value, {3, 7});
      expect(
        () => service.favoriteBookIds.value.add(9),
        throwsUnsupportedError,
      );
      expect(await service.isFavorite(7), isTrue);
      expect(await service.isFavorite(9), isFalse);
      expect(notifications, 1);
    },
  );

  test('toggles favorites, notifies listeners and persists changes', () async {
    final service = FavoriteService();
    final changes = <Set<int>>[];
    service.favoriteBookIds.addListener(
      () => changes.add(service.favoriteBookIds.value),
    );

    await service.toggleFavorite(42);
    expect(await FavoriteService().getFavoriteBookIds(), {42});
    await service.toggleFavorite(42);
    expect(await service.isFavorite(42), isFalse);
    expect(changes, [
      {42},
      <int>{},
    ]);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorite_book_ids_1'), isEmpty);
  });

  test('serializes simultaneous toggles across instances', () async {
    final first = FavoriteService();
    final second = FavoriteService();
    await Future.wait([
      first.toggleFavorite(1),
      second.toggleFavorite(2),
      first.toggleFavorite(1),
    ]);
    expect(await second.getFavoriteBookIds(), {2});
  });

  test('keeps favorites separate for each authenticated user', () async {
    final service = FavoriteService();
    await service.toggleFavorite(1);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', userJson(2));
    expect(await service.getFavoriteBookIds(), isEmpty);
    await service.toggleFavorite(2);
    await prefs.setString('auth_user', userJson(1));
    expect(await service.getFavoriteBookIds(), {1});
  });

  test(
    'reports unauthenticated access and recovers for the next operation',
    () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_user');
      final service = FavoriteService();
      await expectLater(service.toggleFavorite(1), throwsStateError);
      await prefs.setString('auth_user', userJson(1));
      await service.toggleFavorite(2);
      expect(await service.getFavoriteBookIds(), {2});
    },
  );

  test(
    'reports invalid stored IDs rather than silently discarding them',
    () async {
      SharedPreferences.setMockInitialValues({
        'auth_user': userJson(1),
        'favorite_book_ids_1': ['invalid'],
      });
      final service = FavoriteService();
      await expectLater(service.getFavoriteBookIds(), throwsFormatException);
      await expectLater(service.toggleFavorite(1), throwsFormatException);
    },
  );
}
