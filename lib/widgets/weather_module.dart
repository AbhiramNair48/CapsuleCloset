import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/weather_service.dart';
import '../theme/app_design.dart';
import 'glass_container.dart';

class WeatherModule extends StatelessWidget {
  const WeatherModule({super.key});

  @override
  Widget build(BuildContext context) {
    // This needs to be a FutureBuilder or StreamBuilder to handle async data properly
    // reusing the logic from the previous file but with new UI
    
    return FutureBuilder<Map<String, dynamic>>(
      future: context.read<WeatherService>().getCurrentWeather(),
      builder: (context, snapshot) {
        String temp = "--";
        // ignore: unused_local_variable
        String high = "--";
        // ignore: unused_local_variable
        String low = "--";
        
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
           temp = "${snapshot.data!['current_temp']}°";
           high = "${snapshot.data!['max_temp']}°";
           low = "${snapshot.data!['min_temp']}°";
        }

        return GlassContainer(
          width: 80,
          height: 80,
          borderRadius: BorderRadius.circular(50), // Circular
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                temp,
                style: AppText.header.copyWith(fontSize: 22, height: 1),
              ),
              const SizedBox(height: 2),
              Text(
                "H:$high L:$low",
                style: AppText.label.copyWith(fontSize: 9, color: AppColors.accent),
              )
            ],
          ),
        );
      },
    );
  }
}