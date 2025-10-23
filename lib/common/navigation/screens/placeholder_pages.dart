import 'package:flutter/material.dart';

class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Text(
          'Radio Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Text(
          'Library Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF000000),
      body: Center(
        child: Text(
          'Search Page',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }
}
