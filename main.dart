import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String selectedCity = "Київ";
  String temperature = "";
  String condition = "";
  String iconUrl = "";
  bool isLoading = true;

  // Список городов
  final List<String> cities = ["Київ", "Львів", "Карпати", "Житомир"];

  // Карта переводов погодных условий
  final Map<String, String> weatherTranslations = {
    "clear sky": "Ясне небо",
    "few clouds": "Мало хмар",
    "scattered clouds": "Розсіяні хмари",
    "broken clouds": "Хмарно з проясненнями",
    "shower rain": "Злива",
    "rain": "Дощ",
    "thunderstorm": "Гроза",
    "snow": "Сніг",
    "mist": "Туман"
  };

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchWeather(selectedCity); // Загружаем погоду для выбранного города
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$city&appid=288250726a32a6a768914f01ad547cf9&units=metric'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      String weatherCondition = data['weather'][0]['description'];

      setState(() {
        temperature = "${data['main']['temp'].round()}°C";
        condition = weatherTranslations[weatherCondition] ?? weatherCondition;
        iconUrl = "http://openweathermap.org/img/w/${data['weather'][0]['icon']}.png";
        isLoading = false;
      });
    } else {
      setState(() {
        temperature = "Не вдалося отримати погоду";
        condition = "";
        isLoading = false;
      });
    }
  }

  void searchCityWeather() {
    String city = _searchController.text;
    if (city.isNotEmpty) {
      fetchWeather(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Погода'),
        backgroundColor: Colors.black,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.deepPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Основное содержимое экрана
            Center(
              child: isLoading
                  ? CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (iconUrl.isNotEmpty)
                          Image.network(iconUrl, width: 100, height: 100),
                        SizedBox(height: 20),
                        Text(
                          temperature,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          condition,
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
            // Выпадающий список городов вверху слева
            Positioned(
              left: 16,
              top: 20,
              child: DropdownButton<String>(
                value: selectedCity,
                dropdownColor: Colors.deepPurple[900],
                items: cities.map((String city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(
                      city,
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newCity) {
                  setState(() {
                    selectedCity = newCity!;
                  });
                  fetchWeather(selectedCity);
                },
              ),
            ),
            // Поле поиска и кнопка поиска внизу по центру
            Positioned(
              bottom: 50,
              left: MediaQuery.of(context).size.width * 0.25,
              right: MediaQuery.of(context).size.width * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Текстовое поле для ввода
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Введіть місто',
                        hintStyle: TextStyle(color: Colors.white70),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Кнопка поиска
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: searchCityWeather, // Поиск по введенному городу
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
