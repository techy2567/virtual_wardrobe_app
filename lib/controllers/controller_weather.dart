import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherData {
  final double temperature;
  final String condition;
  final String city;

  WeatherData({required this.temperature, required this.condition, required this.city});

  factory WeatherData.fromJson(Map<String, dynamic> json, String city) {
    return WeatherData(
      temperature: json['current']['temperature_2m']?.toDouble() ?? 0.0,
      condition: json['current']['weathercode']?.toString() ?? 'Unknown',
      city: city,
    );
  }
}

class WeatherController extends GetxController {
  var isLoading = false.obs;
  var error = ''.obs;
  var weatherData = Rxn<WeatherData>();
  var locationPermissionDenied = false.obs;
  var locationEnabled = false.obs;
  RxString currentCity = ''.obs;
  var currentPosition = Rxn<Position>();

  @override
  void onInit() {
    super.onInit();
    getCurrentLocationAndFetchWeather();
  }

  Future<void> getCurrentLocationAndFetchWeather() async {
    isLoading.value = true;
    error.value = '';
    locationEnabled.value = false;
    locationPermissionDenied.value = false;
    weatherData.value = null;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        error.value = 'Location services are disabled. Please enable location.';
        locationEnabled.value = false;
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          error.value = 'Location permission denied. Please allow location access.';
          locationPermissionDenied.value = true;
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        error.value = 'Location permissions are permanently denied.';
        locationPermissionDenied.value = true;
        return;
      }
      locationEnabled.value = true;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      currentPosition.value = position;
      await fetchWeatherByLocation(position.latitude, position.longitude);
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lon) async {
    isLoading.value = true;
    error.value = '';
    weatherData.value = null;
    try {
      String cityName = 'Your Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
        if (placemarks.isNotEmpty) {
          cityName = placemarks.first.locality ?? placemarks.first.administrativeArea ?? 'Your Location';
          currentCity.value = cityName;
        }
      } catch (_) {}
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        weatherData.value = WeatherData(
          temperature: data['current_weather']['temperature']?.toDouble() ?? 0.0,
          condition: _mapWeatherCodeToString(data['current_weather']['weathercode']),
          city: cityName,
        );
      } else {
        error.value = 'Failed to fetch weather data.';
      }
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeather({String city = 'London'}) async {
    isLoading.value = true;
    error.value = '';
    weatherData.value = null;
    try {
      // For demo, use static coordinates for London. You can use a geocoding API for real city lookup.
      double lat = 51.5074;
      double lon = -0.1278;
      if (city.toLowerCase() == 'new york') {
        lat = 40.7128;
        lon = -74.0060;
      } else if (city.toLowerCase() == 'paris') {
        lat = 48.8566;
        lon = 2.3522;
      }
      final url = 'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        weatherData.value = WeatherData(
          temperature: data['current_weather']['temperature']?.toDouble() ?? 0.0,
          condition: _mapWeatherCodeToString(data['current_weather']['weathercode']),
          city: city,
        );
      } else {
        error.value = 'Failed to fetch weather data.';
      }
    } catch (e) {
      error.value = 'Error: $e';
    } finally {
      isLoading.value = false;
    }
  }

  String _mapWeatherCodeToString(dynamic code) {
    // Map Open-Meteo weather codes to simple strings
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 80:
      case 81:
      case 82:
        return 'Showers';
      case 95:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}