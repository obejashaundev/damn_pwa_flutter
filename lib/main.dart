// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import './src/pages/busqueda.dart';
import './src/pages/pantalla_principal.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Damn',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        //142.44.149.161:22
        /* '/': (context) => Login(), */
        '/': (context) => PantallaPrincipal(),
        '/pantalla_principal/busqueda': (context) => Busqueda(),
      },
    );
  }
}
