import 'package:flutter/material.dart';
import 'main_page.dart';

class Beathub extends StatefulWidget {
  const Beathub({super.key});

  @override
  State<Beathub> createState() => _BeathubState();
}

class _BeathubState extends State<Beathub> {
  @override
  Widget build(BuildContext context) {
    const title = "Beathub";
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.orange,  
          textTheme: ButtonTextTheme.primary,  
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.orange, 
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        useMaterial3: true,

      ),
      home: const MainPage(title: title),
    );
  }
}