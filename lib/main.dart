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
  final List<String> types;
  final bool isShiny;
  final String spriteUrl;

  // Get Pokemon name, ID, and types
  Pokemon({required this.name, required this.id, required this.types, required this.isShiny, required this.spriteUrl});

  factory Pokemon.fromJson(Map<String, dynamic> json, bool isShiny, String spriteUrl) {
    return Pokemon(
      name: capitalize(json['name']),
      id: json['id'],
      types: (json['types'] as List<dynamic>)
          .map((type) => capitalize(type['type']['name'].toString()))
          .toList(),
      isShiny: isShiny,
      spriteUrl: spriteUrl, // Set the spriteUrl property
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
  List<Pokemon> _pokemonTeam = [];

  @override
  void initState() {
    super.initState();
    _pokemon = fetchPokemon();
    _pokemonTypes = fetchPokemonTypes();
  }

  Future<Pokemon> fetchPokemon() async {
    final randomPokemonId = Random().nextInt(898) + 1;
    final isShiny = Random().nextInt(10) == 0; // 10% chance for a shiny Pokémon

    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$randomPokemonId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String spriteUrl = isShiny
          ? data['sprites']['front_shiny']
          : data['sprites']['front_default'];

      return Pokemon.fromJson(data, isShiny, spriteUrl);
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
    final randomPokemonId = Random().nextInt(898) + 1;
    final isShiny = Random().nextInt(5) == 0; // 5% chance for a shiny Pokémon

    setState(() {
      _pokemon = fetchPokemonById(randomPokemonId, isShiny);
      _pokemonTypes = fetchPokemonTypesById(randomPokemonId);
    });
  }

  Future<Pokemon> fetchPokemonById(int id, [bool isShiny = false]) async {
    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String spriteUrl = isShiny
          ? data['sprites']['front_shiny']
          : data['sprites']['front_default'];

      return Pokemon.fromJson(data, isShiny, spriteUrl);
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

  void _removeFromTeam(int index) {
    setState(() {
      _pokemonTeam.removeAt(index);
    });
  }

  Widget _buildPokemonTeamContainer() {
    String getMostCommonType() {
      if (_pokemonTeam.isEmpty) {
        return 'No Pokemon in the team';
      }

      // Count occurrences of each type
      final typeCounts = <String, int>{};
      _pokemonTeam.forEach((pokemon) {
        pokemon.types.forEach((type) {
          typeCounts[type] = (typeCounts[type] ?? 0) + 1;
        });
      });

      // Find the type with the maximum occurrence
      final mostCommonType = typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      return 'Most Common Type: $mostCommonType';
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      width: 360,
      color: Colors.black.withOpacity(0.7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Team',
            style: TextStyle(color: Colors.white, fontSize: 32.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 60.0,
            ),
            itemCount: _pokemonTeam.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1.0),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: GestureDetector(
                        onTap: () => _removeFromTeam(index),
                        child: Image.network(
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${_pokemonTeam[index].id}.png',
                          height: 200,
                          width: 200,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      '${_pokemonTeam[index].name}',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      'Type: ${_pokemonTeam[index].types.join(' / ')}',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 16.0),
          Text(
            getMostCommonType(),
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ],
      ),
    );
  }

  void _addToTeam(Pokemon pokemon) {
    if (_pokemonTeam.length < 6) {
      final spriteUrl = pokemon.isShiny
          ? pokemon.spriteUrl
          : 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png';

      final shinyPokemon = Pokemon(
        name: pokemon.name,
        id: pokemon.id,
        types: pokemon.types,
        isShiny: pokemon.isShiny,
        spriteUrl: spriteUrl,
      );

      setState(() {
        _pokemonTeam.add(shinyPokemon);
      });
    } else {
      // Team is full, show a snackbar
      final snackBar = SnackBar(
        content: Text('Your team is full!! Remove a Pokemon by clicking on it!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Row(
        children: [
          _buildPokemonTeamContainer(),
          Expanded(
            child: Stack(
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
                                  height: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    border: Border.all(color: Colors.black, width: 2.0),
                                  ),
                                  child: Image.network(
                                    pokemon.spriteUrl,
                                    height: 200,
                                    width: 200,
                                  ),

                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  'Type: ${types.join(' / ')}',
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                SizedBox(height: 8.0),
                                Text(
                                  '${pokemon.name}',
                                  style: TextStyle(color: Colors.white, fontSize: 20),
                                ),

                                SizedBox(height: 8.0),  // Add space between the buttons

                                ElevatedButton(
                                  onPressed: _generateRandomPokemon,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: Text(
                                    'Generate New Pokemon',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 8.0),  // Add space between the buttons

                                ElevatedButton(
                                  onPressed: () => _addToTeam(pokemon),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // Adjust the color as needed
                                  ),
                                  child: Text(
                                    'Add to Team',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}
