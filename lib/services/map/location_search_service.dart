import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:touring_game/core/errors/app_exception.dart';
import 'package:touring_game/models/address.dart';
import 'package:http/http.dart' as http;

class LocationSearchApiService {
  LocationSearchApiService(
    this._client, {
    this.minimumRequestInterval = const Duration(seconds: 1),
    DateTime Function()? now,
    Future<void> Function(Duration)? delay,
  }) : _now = now ?? DateTime.now,
       _delay = delay ?? Future<void>.delayed;

  final http.Client _client;
  final Duration minimumRequestInterval;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _delay;
  final LinkedHashMap<String, List<AddressModel>> _cache = LinkedHashMap();
  final Map<String, Future<List<AddressModel>>> _inFlight = {};
  DateTime? _nextRequestAt;

  static const _maximumCacheEntries = 50;

  void close() => _client.close();

  Future<List<AddressModel>> fetchAddress(String searchedText) async {
    final query = searchedText.trim();
    if (query.isEmpty) {
      return const [];
    }
    final cacheKey = query.toLowerCase();
    final cached = _cache.remove(cacheKey);
    if (cached != null) {
      _cache[cacheKey] = cached;
      return cached;
    }
    final pending = _inFlight[cacheKey];
    if (pending != null) {
      return pending;
    }
    final request = _rateLimitedRequest(query, cacheKey);
    _inFlight[cacheKey] = request;
    try {
      return await request;
    } finally {
      _inFlight.remove(cacheKey);
    }
  }

  Future<List<AddressModel>> _rateLimitedRequest(
    String query,
    String cacheKey,
  ) async {
    final now = _now();
    final scheduledAt = _nextRequestAt != null && _nextRequestAt!.isAfter(now)
        ? _nextRequestAt!
        : now;
    _nextRequestAt = scheduledAt.add(minimumRequestInterval);
    final wait = scheduledAt.difference(now);
    if (wait > Duration.zero) {
      await _delay(wait);
    }

    final result = await _performRequest(query);
    _cache[cacheKey] = result;
    if (_cache.length > _maximumCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
    return result;
  }

  Future<List<AddressModel>> _performRequest(String searchedText) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': searchedText,
      'addressdetails': '1',
      'format': 'jsonv2',
      'limit': '10',
    });
    try {
      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent':
                  'touring-game/0.1.0 (https://github.com/mis177/touring-game)',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as List<dynamic>;
        return decoded
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList(growable: false);
      }
      throw NetworkException(
        'Address search failed with status ${response.statusCode}.',
      );
    } on NetworkException {
      rethrow;
    } on TimeoutException catch (error) {
      throw NetworkException('Address search timed out.', error);
    } on http.ClientException catch (error) {
      throw NetworkException('Could not connect to address search.', error);
    } on FormatException catch (error) {
      throw NetworkException('Address search returned invalid data.', error);
    } on TypeError catch (error) {
      throw NetworkException('Address search returned invalid data.', error);
    }
  }
}
