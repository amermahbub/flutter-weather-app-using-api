import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  final String apiKey = '7aab710a86685861591af59d2f4baf20';
  final String apiUrl =
      'https://api.openweathermap.org/data/2.5/weather?units=metric';

  bool isLoading = false;
  bool hasError = false;
  WeatherData? weatherData;
  String locationName = '';
  DateTime lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      var userLocation = await getCurrentLocation();
      var url = Uri.parse(
          '$apiUrl&lat=${userLocation.latitude}&lon=${userLocation.longitude}&appid=$apiKey');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          weatherData = WeatherData.fromJson(jsonData);
          locationName = jsonData['name'];
          isLoading = false;
          hasError = false;
          lastUpdateTime = DateTime.now();
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<UserLocation> getCurrentLocation() async {
    return UserLocation(
        latitude: 40.7128,
        longitude: -74.0060); // Set the latitude and longitude of New York
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Weather App'),
        ),
        body: Container(
          color: Colors.purple[200],
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : hasError
                    ? Text('Failed to fetch weather data')
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            weatherData!.temperature.toStringAsFixed(1) + '°C',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          CachedNetworkImage(
                            imageUrl:
                                'https://openweathermap.org/img/wn/${weatherData!.icon}.png',
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(height: 16),
                          Text(
                            weatherData!.description,
                            style: TextStyle(fontSize: 24),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Location: $locationName',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Last Update: ${lastUpdateTime.toString()}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Min Temp: ${weatherData!.minTemp.toStringAsFixed(1)}°C',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Max Temp: ${weatherData!.maxTemp.toStringAsFixed(1)}°C',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

class WeatherData {
  final double temperature;
  final String description;
  final String icon;
  final double minTemp;
  final double maxTemp;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.icon,
    required this.minTemp,
    required this.maxTemp,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    var main = json['main'];
    var weather = json['weather'][0];
    return WeatherData(
      temperature: main['temp'].toDouble(),
      description: weather['description'],
      icon: weather['icon'],
      minTemp: main['temp_min'].toDouble(),
      maxTemp: main['temp_max'].toDouble(),
    );
  }
}

class UserLocation {
  final double latitude;
  final double longitude;

  UserLocation({required this.latitude, required this.longitude});
}
