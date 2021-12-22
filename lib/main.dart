import 'dart:convert';
import 'package:climate/searchscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

String apikey = 'd527098931e368f1ffa572e4a83cc449';
String temp = '0';
String humidity = '0';
String maxTemp = '0';
String minTemp = '0';
String cityName = 'Delhi';
String savedCityName = '';

Future<http.Response> callApi(String city) async {
  print('Data api call is being done');
  var response = await http.get(
    Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apikey&units=metric'),
  );
  print(
      'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apikey&units=metric');
  print(response.body);
  // var weatherData = jsonDecode(response.body);

  // print(weatherData['main']['temp']);
  // temp = weatherData['main']['temp'].toString();
  // humidity = weatherData['main']['humidity'].toString();
  // maxTemp = weatherData['main']['temp_max'].toString();
  // minTemp = weatherData['main']['temp_min'].toString();
  return response;
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    final prefs = SharedPreferences.getInstance();
    prefs.then((prefs) {
      setState(() {
        cityName = prefs.getString('cityName') ?? 'Delhi';
        try {
          callApi(cityName).then((value) {
            var weatherData = jsonDecode(value.body);
            if (weatherData['coord'] != null) {
              setState(() {
                savedCityName = weatherData['name'].toString().toUpperCase();
                print(weatherData['main']['temp']);
                cityName = weatherData['name'];
                temp = weatherData['main']['temp'].toString();
                humidity = weatherData['main']['humidity'].toString();
                maxTemp = weatherData['main']['temp_max'].toString();
                minTemp = weatherData['main']['temp_min'].toString();
              });
            } else {
              final snackBar = SnackBar(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                content: Text(weatherData['message'],
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    // Some code to undo the change.
                  },
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            }
          });
        } catch (e) {
          final snackBar = SnackBar(
            content: const Text('Something went wrong'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          print(e);
        }
      });
    });
    print(cityName);
    // TODO: implement initState

    super.initState();
  }

  void loadCity() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      cityName = (prefs.getString('cityName') ?? 'Patna');
      print(cityName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
            onTap: () async {
              // save the city name to shared prefrences
              final prefs = await SharedPreferences.getInstance();
              prefs.setString('cityName', cityName);
              final snackBar = SnackBar(
                content: const Text('City name saved'),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            child: Icon(
              Icons.favorite,
              color: cityName.toUpperCase() == savedCityName
                  ? Colors.red
                  : Colors.white,
            )),
        title: Text('Weather App'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              var city = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
              try {
                var res = await callApi(city);
                var weatherData = jsonDecode(res.body);
                if (weatherData['coord'] != null) {
                  setState(() {
                    cityName = weatherData['name'].toString();
                    temp = weatherData['main']['temp'].toString();
                    humidity = weatherData['main']['humidity'].toString();
                    maxTemp = weatherData['main']['temp_max'].toString();
                    minTemp = weatherData['main']['temp_min'].toString();
                  });
                } else {
                  final snackBar = SnackBar(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    content: Text(weatherData['message'],
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              } catch (e) {
                final snackBar = SnackBar(
                  content: const Text('Something went wrong'),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                print(e);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(height: 100),
              Text(
                '$temp°  ',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' C',
                style: TextStyle(
                  fontSize: 100,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                height: 30,
              ),
              Text(
                cityName.toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3,
                ),
              ),
              Container(
                height: 70,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sunny',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Humidity = $humidity %',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        'Max = $maxTemp°C',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Min = $minTemp °C',
                        style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
