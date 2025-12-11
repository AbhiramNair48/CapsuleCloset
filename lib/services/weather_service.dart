import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // 1. Get Location
      Position position = await _determinePosition();

      // 2. Call Open-Meteo API
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max,weather_code&forecast_days=1&temperature_unit=fahrenheit');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final currentTemp = data['current']['temperature_2m'];
        final currentWeatherCode = data['current']['weather_code'];
        final daily = data['daily'];
        final maxTemp = daily['temperature_2m_max'][0];
        final minTemp = daily['temperature_2m_min'][0];
        final precipChance = daily['precipitation_probability_max'][0];
        final dailyWeatherCode = daily['weather_code'][0]; // Use first day's weather code

        return {
          'current_temp': currentTemp,
          'current_weather_code': currentWeatherCode,
          'max_temp': maxTemp,
          'min_temp': minTemp,
          'precip_chance': precipChance,
          'daily_weather_code': dailyWeatherCode,
          'unit': data['current_units']['temperature_2m'] ?? '°C',
        };
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      // Return null or throw depending on how we want to handle it.
      // For now, let's return null to indicate failure without crashing.
      debugPrint('Weather Error: $e');
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
      locationSettings: const LocationSettings(timeLimit: Duration(seconds: 5)),
    );
  }
}
