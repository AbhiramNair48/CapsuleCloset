import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class _WeatherCacheItem {
  final Map<String, dynamic> data;
  final DateTime timestamp;

  _WeatherCacheItem(this.data, this.timestamp);
}

class WeatherService extends ChangeNotifier {
  final Map<String, _WeatherCacheItem> _cache = {};
  static const Duration _cacheDuration = Duration(minutes: 30);
  Position? _lastFetchPosition;

  Map<String, dynamic> _currentWeather = {};
  bool _isFetching = false;

  Map<String, dynamic> get currentWeather => _currentWeather;
  bool get isFetching => _isFetching;

  Future<Map<String, dynamic>> getCurrentWeather() async {
    if (_isFetching) return _currentWeather;
    
    try {
      // Optimization: Check if we have a valid cache for the last known position
      if (_lastFetchPosition != null) {
        final cacheKey =
            '${_lastFetchPosition!.latitude.toStringAsFixed(2)},${_lastFetchPosition!.longitude.toStringAsFixed(2)}';
        if (_cache.containsKey(cacheKey)) {
          final cachedItem = _cache[cacheKey]!;
          final age = DateTime.now().difference(cachedItem.timestamp);
          if (age < _cacheDuration) {
            debugPrint('Returning fast cached weather data for $cacheKey');
            _currentWeather = cachedItem.data;
            return _currentWeather;
          }
        }
      }

      _isFetching = true;
      notifyListeners();

      // 1. Get Location
      Position position = await _determinePosition();
      _lastFetchPosition = position;

      // Generate a cache key based on location (rounded to 2 decimal places approx 1.1km)
      final String cacheKey =
          '${position.latitude.toStringAsFixed(2)},${position.longitude.toStringAsFixed(2)}';

      // Check cache
      if (_cache.containsKey(cacheKey)) {
        final cachedItem = _cache[cacheKey]!;
        final age = DateTime.now().difference(cachedItem.timestamp);
        if (age < _cacheDuration) {
          debugPrint(
              'Returning cached weather data for $cacheKey (Age: ${age.inMinutes} mins)');
          _currentWeather = cachedItem.data;
          _isFetching = false;
          notifyListeners();
          return _currentWeather;
        } else {
          _cache.remove(cacheKey); // Expired
        }
      }

      // 2. Call Open-Meteo API
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&forecast_days=1&temperature_unit=fahrenheit');

      final response = await http.get(url).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timed out');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final currentTemp = data['current']['temperature_2m'];
        final currentWeatherCode = data['current']['weather_code'];
        final daily = data['daily'];
        final maxTemp = daily['temperature_2m_max'][0];
        final minTemp = daily['temperature_2m_min'][0];
        final precipChance = daily['precipitation_probability_max'][0];
        final dailyWeatherCode = daily['weather_code'][0]; // Use first day's weather code

        final weatherData = {
          'current_temp': currentTemp,
          'current_weather_code': currentWeatherCode,
          'max_temp': maxTemp,
          'min_temp': minTemp,
          'precip_chance': precipChance,
          'daily_weather_code': dailyWeatherCode,
          'unit': data['current_units']['temperature_2m'] ?? '°F',
        };

        // Update cache
        _cache[cacheKey] = _WeatherCacheItem(weatherData, DateTime.now());
        _currentWeather = weatherData;
        _isFetching = false;
        notifyListeners();

        return weatherData;
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      debugPrint('Weather Error: $e');
      _isFetching = false;
      notifyListeners();
      return {};
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low, // Lower accuracy is faster
        timeLimit: Duration(seconds: 10), // Increased from 5s
      ),
    );
  }
}
