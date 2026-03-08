import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

class WeatherModule extends StatelessWidget {
  const WeatherModule({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherService = context.watch<WeatherService>();
    final data = weatherService.currentWeather;
    final isFetching = weatherService.isFetching;

    String temp = "--";
    String high = "--";
    String low = "--";

    if (data.isNotEmpty) {
      temp = "${data['current_temp']}°";
      high = "${data['max_temp']}°";
      low = "${data['min_temp']}°";
    }

    // Trigger fetch if empty and not fetching
    if (data.isEmpty && !isFetching) {
      Future.microtask(() {
        if (context.mounted) {
          context.read<WeatherService>().getCurrentWeather();
        }
      });
    }

    return GlassContainer(
      width: 85,
      height: 85,
      borderRadius: BorderRadius.circular(50),
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isFetching && data.isEmpty)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
            )
          else ...[
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                temp,
                style: AppText.header.copyWith(fontSize: 20, height: 1),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "H:$high L:$low",
                style: AppText.label.copyWith(fontSize: 8, color: AppColors.accent),
              ),
            ),
          ]
        ],
      ),
    );
  }
}