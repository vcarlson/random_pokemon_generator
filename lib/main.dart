import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

String capitalize(String s) {
  return s[0].toUpperCase() + s.substring(1);
}


class Pokemon {
  final String name;
  final int id;

  //Get Pokemon name and ID
  Pokemon({required this.name, required this.id});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: capitalize(json['name']),
      id: json['id'],
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Random Pokemon Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Pokemon Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<Pokemon> _pokemon;

  @override
  void initState() {
    super.initState();
    _pokemon = fetchPokemon();
  }

  Future<Pokemon> fetchPokemon() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Pokemon.fromJson(data);
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Image.network(
            'https://static1.thegamerimages.com/wordpress/wp-content/uploads/2019/09/Webp.net-resizeimage-18.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.center,
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: FutureBuilder<Pokemon>(
                future: _pokemon,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Pokemon Name: ${snapshot.data!.name}',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        Text(
                          'Pokemon ID: ${snapshot.data!.id}',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
