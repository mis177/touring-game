import 'package:flutter_test/flutter_test.dart';
import 'package:touring_game/models/activity.dart';
import 'package:touring_game/models/coordinates.dart';
import 'package:touring_game/services/game/bloc/activities/activities_cubit.dart';

void main() {
  const finished = DatabaseActivity(
    id: 'finished',
    name: 'Museum',
    webUrl: 'https://example.com',
    isDone: true,
    coords: Coordinates(latitude: 1, longitude: 2),
    placeId: 'place',
  );
  const unfinished = DatabaseActivity(
    id: 'unfinished',
    name: 'Park',
    webUrl: 'https://example.com',
    isDone: false,
    coords: Coordinates(latitude: 1, longitude: 2),
    placeId: 'place',
  );

  test('text and status filters compose and can be cleared', () {
    final cubit = ActivitiesCubit(const [finished, unfinished]);

    cubit.search('museum');
    cubit.toggleFilter(ActivityStatusFilter.finished);
    expect(cubit.state.activities, const [finished]);

    cubit.toggleFilter(ActivityStatusFilter.finished);
    expect(cubit.state.activities, const [finished]);

    cubit.search('');
    expect(cubit.state.activities, const [finished, unfinished]);

    cubit.close();
  });
}
