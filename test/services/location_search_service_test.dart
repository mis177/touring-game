import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:touring_game/services/map/location_search_service.dart';

void main() {
  const responseBody =
      '[{"display_name":"Krakow","lat":"50.061","lon":"19.938"}]';

  test('reuses cached results for an equivalent submitted query', () async {
    var requestCount = 0;
    final service = LocationSearchApiService(
      MockClient((request) async {
        requestCount++;
        return http.Response(responseBody, 200);
      }),
      minimumRequestInterval: Duration.zero,
    );

    final first = await service.fetchAddress(' Krakow ');
    final second = await service.fetchAddress('krakow');

    expect(requestCount, 1);
    expect(second, first);
    service.close();
  });

  test('waits at least the configured interval between requests', () async {
    var now = DateTime.utc(2026);
    final waits = <Duration>[];
    final service = LocationSearchApiService(
      MockClient((request) async => http.Response(responseBody, 200)),
      now: () => now,
      delay: (duration) async {
        waits.add(duration);
        now = now.add(duration);
      },
    );

    await service.fetchAddress('Krakow');
    await service.fetchAddress('Warsaw');

    expect(waits, [const Duration(seconds: 1)]);
    service.close();
  });
}
