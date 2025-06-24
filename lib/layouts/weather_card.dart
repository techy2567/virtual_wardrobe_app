import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller_weather.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final WeatherController controller = Get.put(WeatherController());

    return Obx(() {
      if (controller.isLoading.value) {
        return Skeletonizer(
          enabled: true,
          child: Card(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: SizedBox(
              height: 170,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 80, height: 18, color: Colors.grey[300]),
                          const SizedBox(height: 8.0),
                          Container(width: 60, height: 14, color: Colors.grey[300]),
                          const SizedBox(height: 8.0),
                          Container(width: 50, height: 32, color: Colors.grey[300]),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Container(width: 60, height: 60, color: Colors.grey[300]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
      if (controller.error.value.isNotEmpty) {
        String displayError = controller.error.value;
        if (!controller.locationPermissionDenied.value) {
          displayError = 'Unable to fetch weather. Please try again later.';
        }
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: SizedBox(
            height: 170,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, color: colorScheme.primary, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    displayError,
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  if (controller.locationPermissionDenied.value)
                    TextButton(
                      onPressed: () => controller.getCurrentLocationAndFetchWeather(),
                      child: const Text('Enable Location'),
                    ),
                ],
              ),
            ),
          ),
        );
      }
      final weather = controller.weatherData.value;
      if (weather == null) {
        return Card(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${controller.currentCity.value.isEmpty ? 'Layyah': controller.currentCity.value}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 15,
                          color: colorScheme.primary.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '22.0°C',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Flexible(
                        child: Row(
                          children: [
                            Icon(Icons.water_drop, size: 18, color: colorScheme.primary.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Flexible(child: Text('Humidity: 60%', style: TextStyle(color: colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis)),
                            const SizedBox(width: 12),
                            Icon(Icons.air, size: 18, color: colorScheme.primary.withOpacity(0.7)),
                            const SizedBox(width: 4),
                            Flexible(child: Text('Wind: 10 km/h', style: TextStyle(color: colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Icon(Icons.thermostat, size: 60, color: colorScheme.primary.withOpacity(0.8)),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      (weather.city == 'Your Location' || weather.city.isEmpty) ? 'City' : weather.city,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      weather.condition,
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.primary.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(children: [
                      Icon(Icons.water_drop, size: 18, color: colorScheme.primary.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text('Humidity: 60%', style: TextStyle(color: colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis),

                    ],),
                     Row(children: [
                       Icon(Icons.air, size: 18, color: colorScheme.primary.withOpacity(0.7)),
                       const SizedBox(width: 4),
                       Text('Wind: 10 km/h', style: TextStyle(color: colorScheme.primary.withOpacity(0.7)), overflow: TextOverflow.ellipsis),

                     ],)
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: Icon(Icons.thermostat, size: 120, color: colorScheme.primary.withOpacity(0.8)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _weatherIcon(String condition, ColorScheme colorScheme) {
    switch (condition) {
      case 'Clear':
        return Icon(Icons.wb_sunny, size: 60, color: colorScheme.primary.withOpacity(0.8));
      case 'Partly Cloudy':
        return Icon(Icons.cloud_queue, size: 60, color: colorScheme.primary.withOpacity(0.7));
      case 'Rain':
      case 'Showers':
        return Icon(Icons.grain, size: 60, color: colorScheme.primary.withOpacity(0.7));
      case 'Snow':
        return Icon(Icons.ac_unit, size: 60, color: colorScheme.primary.withOpacity(0.7));
      case 'Thunderstorm':
        return Icon(Icons.flash_on, size: 60, color: colorScheme.primary.withOpacity(0.7));
      case 'Fog':
        return Icon(Icons.blur_on, size: 60, color: colorScheme.primary.withOpacity(0.7));
      default:
        return Icon(Icons.cloud_outlined, size: 60, color: colorScheme.primary.withOpacity(0.7));
    }
  }
} 