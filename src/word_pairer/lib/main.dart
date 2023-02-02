import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Word Pairer',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: Navigation(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite({WordPair? favorite}) {
    favorite ??= current;

    favorites.contains(favorite)
        ? favorites.remove(favorite)
        : favorites.add(favorite);

    print(favorites);
    notifyListeners();
  }
}

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          alignment: Alignment.center,
          child: GeneratorPage(),
        ),
        Container(
          alignment: Alignment.center,
          child: FavoritesPage(),
        ),
      ][currentPageIndex],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var getNext = appState.getNext;
    var toggleFavorite = appState.toggleFavorite;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Scaffold(
      backgroundColor: Colors.deepOrange[100],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BigCard(pair: pair),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionButton(action: toggleFavorite, label: "Like", icon: icon),
                SizedBox(
                  width: 10,
                ),
                ActionButton(
                    action: getNext, label: "Next", icon: Icons.forward),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var toggleFavorite = appState.toggleFavorite;
    var theme = Theme.of(context);
    var style =
        theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onPrimary);

    return Scaffold(
      backgroundColor: Colors.red[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(children: [
          for (var fav in favorites)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor: Colors.red[200],
                title: Text(style: style, fav.toString()),
                trailing:
                    Icon(Icons.favorite, color: theme.colorScheme.primary),
                onTap: () {
                  toggleFavorite(favorite: fav);
                },
              ),
            )
        ]),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton(
      {super.key, required this.action, this.label = "", this.icon});

  final void Function() action;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: () {
          action();
        },
        icon: Icon(icon),
        label: Text(label));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium
        ?.copyWith(color: theme.colorScheme.onPrimary, shadows: null);

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}
