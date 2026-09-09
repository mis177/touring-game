import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/game/bloc/activity_details/activity_details_cubit.dart';

import '../helpers/fake_game_repository.dart';

void main() {
  const activity = DatabaseActivity(
    id: 'activity',
    name: 'Museum',
    webUrl: 'https://example.com',
    isDone: false,
    coords: Coordinates(latitude: 1, longitude: 2),
    placeId: 'place',
  );

  test('failed completion update rolls back optimistic state', () async {
    final failure = Exception('write failed');
    final cubit = ActivityDetailsCubit(
      FakeGameRepository(updateError: failure),
      activity,
    );

    await cubit.updateDone(true);

    expect(cubit.state.activity, activity);
    expect(cubit.state.isSaving, isFalse);
    expect(cubit.state.exception, same(failure));
    await cubit.close();
  });
}
