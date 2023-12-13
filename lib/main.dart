import 'dart:convert';
import 'dart:math';
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
  late Future<List<String>> _pokemonTypes;

  @override
  void initState() {
    super.initState();
    _pokemon = fetchPokemon();
    _pokemonTypes = fetchPokemonTypes();
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

  Future<List<String>> fetchPokemonTypes() async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/1'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> types = data['types'];
      return types.map((type) => capitalize(type['type']['name'].toString())).toList();
    } else {
      throw Exception('Failed to load Pokemon types');
    }
  }

  Future<void> _generateRandomPokemon() async {
    // Generate a random Pokemon ID between 1 and 898 (total number of Pokemon in the API)
    final randomPokemonId = Random().nextInt(898) + 1;

    setState(() {
      _pokemon = fetchPokemonById(randomPokemonId);
      _pokemonTypes = fetchPokemonTypesById(randomPokemonId);
    });
  }

  Future<Pokemon> fetchPokemonById(int id) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Pokemon.fromJson(data);
    } else {
      throw Exception('Failed to load Pokemon');
    }
  }

  Future<List<String>> fetchPokemonTypesById(int id) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> types = data['types'];
      return types.map((type) => capitalize(type['type']['name'].toString())).toList();
    } else {
      throw Exception('Failed to load Pokemon types');
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
              child: FutureBuilder(
                future: Future.wait([_pokemon, _pokemonTypes]),
                builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final Pokemon pokemon = snapshot.data![0];
                    final List<String> types = snapshot.data![1];

                    return Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            'Pokemon ID: ${pokemon.id}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 4.0),
                          Container(
                            height: 350,
                            width: 350,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.black, width: 2.0),
                            ),
                            child: Image.network(
                              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Pokemon Type: ${types.join(' / ')}',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Pokemon Name: ${pokemon.name}',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          ElevatedButton(
                            onPressed: _generateRandomPokemon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: Text(
                              'Generate New Pokemon',
                              style: TextStyle(color: Colors.white),
                            ),
                          )

                        ],
                      ),
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



