import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/note.dart';
import 'package:touring_game/services/demo/demo_auth_repository.dart';
import 'package:touring_game/services/demo/demo_game_repository.dart';
import 'package:touring_game/services/demo/demo_map_repositories.dart';

void main() {
  group('demo repositories', () {
    test('provide a ready-to-use verified account', () async {
      final repository = DemoAuthRepository();

      await repository.initialize();

      expect(repository.currentUser, DemoAuthRepository.demoUser);
      expect(repository.currentUser?.isEmailVerified, isTrue);
    });

    test('persist activity completion and note changes in memory', () async {
      final repository = DemoGameRepository();
      final catalog = await repository.loadCatalog();
      final activity = catalog.activities.first;

      await repository.updateActivityDone(activity.copyWith(isDone: true));
      expect((await repository.loadCatalog()).activities.first.isDone, isTrue);

      const note = DatabaseNote(
        id: 'new-note',
        activityId: 'wawel',
        content: 'Portfolio note',
        color: '4294961979',
        positionX: 0.5,
        positionY: 0.5,
        isImage: false,
        imagePath: null,
      );
      await repository.saveNote(note);
      expect(await repository.loadNotes('wawel'), contains(note));

      final updated = note.copyWith(content: 'Updated note');
      await repository.updateNote(note, updated);
      expect(await repository.loadNotes('wawel'), contains(updated));

      await repository.deleteNote(updated);
      expect(await repository.loadNotes('wawel'), isNot(contains(updated)));
    });

    test('searches local demo addresses without network access', () async {
      final repository = DemoPlaceSearchRepository();

      final results = await repository.search('wawel');

      expect(results, hasLength(1));
      expect(results.single.name.toLowerCase(), contains('wawel'));
    });
  });
}
