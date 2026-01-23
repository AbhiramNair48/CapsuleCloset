import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';

/// Weather module to display current weather conditions with an icon
class WeatherModule extends StatefulWidget {
  const WeatherModule({super.key});

  @override
  State<WeatherModule> createState() => _WeatherModuleState();
}

class _WeatherModuleState extends State<WeatherModule> {
  bool _isLoading = true;
  Map<String, dynamic>? _weatherData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weatherService = context.read<WeatherService>();
      final weatherData = await weatherService.getCurrentWeather();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _weatherData = weatherData;
          _error = weatherData.isEmpty ? "Failed to load weather data" : null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  IconData _getWeatherIcon() {
    if (_weatherData == null) return Icons.cloud_outlined;

    // Use the daily weather code for icon selection
    final dailyWeatherCode = _weatherData!['daily_weather_code'];

    if (dailyWeatherCode != null) {
      final code = dailyWeatherCode is int ? dailyWeatherCode : int.tryParse(dailyWeatherCode.toString());

      if (code != null) {
        // Use WMO weather codes to determine icon
        // Reference: https://open-meteo.com/en/docs
        switch (code) {
          case 0: // Clear sky
            return Icons.wb_sunny;
          case 1: // Mainly clear
          case 2: // Partly cloudy
          case 3: // Overcast
            return Icons.wb_cloudy;
          case 45: // Fog
          case 48: // Depositing rime fog
            return Icons.foggy;
          case 51: // Drizzle light
          case 53: // Drizzle moderate
          case 55: // Drizzle dense
          case 56: // Freezing Drizzle light
          case 57: // Freezing Drizzle dense
          case 61: // Rain slight
          case 63: // Rain moderate
          case 65: // Rain heavy
          case 66: // Freezing Rain light
          case 67: // Freezing Rain heavy
          case 80: // Rain showers slight
          case 81: // Rain showers moderate
          case 82: // Rain showers violent
            return Icons.umbrella;
          case 71: // Snow fall slight
          case 73: // Snow fall moderate
          case 75: // Snow fall heavy
          case 77: // Snow grains
          case 85: // Snow showers slight
          case 86: // Snow showers heavy
            return Icons.ac_unit; // Using AC unit icon for snow
          case 95: // Thunderstorm
          case 96: // Thunderstorm with slight hail
          case 97: // Thunderstorm with heavy hail
            return Icons.thunderstorm;
          default:
            return Icons.cloud_outlined;
        }
      }
    }

    // Fallback to original logic if no weather code is available
    final maxTemp = _weatherData!['max_temp'];
    final precipChance = _weatherData!['precip_chance'];

    if (precipChance != null) {
      final precipValue = double.tryParse(precipChance.toString());
      if (precipValue != null && precipValue > 60) {
        return Icons.umbrella;
      }
    }

    if (maxTemp != null) {
      final maxTempValue = double.tryParse(maxTemp.toString());
      if (maxTempValue != null && maxTempValue > 75) {
        return Icons.wb_sunny;
      }
    }

    return Icons.cloud_outlined;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const SizedBox(
          width: 24.0,
          height: 24.0,
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
      );
    }

    if (_error != null || _weatherData == null || _weatherData!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Icon(Icons.error_outline),
      );
    }

    final currentTemp = _weatherData!['current_temp'];
    final maxTemp = _weatherData!['max_temp'];
    final minTemp = _weatherData!['min_temp'];
    final unit = _weatherData!['unit'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getWeatherIcon()),
          const SizedBox(width: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentTemp != null ? '$currentTemp$unit' : 'N/A',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Row(
                children: [
                  Text(
                    maxTemp != null ? 'Hi: $maxTemp$unit' : 'Hi: N/A',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    minTemp != null ? 'Lo: $minTemp$unit' : 'Lo: N/A',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
