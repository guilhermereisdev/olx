import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:olx/utils/temas.dart';
import 'package:olx/views/screens/anuncios.dart';

import 'configs/firebase_options.dart';
import 'configs/route_generator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "OLX",
    home: const Anuncios(),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoutes,
    theme: themeData,
    debugShowCheckedModeBanner: false,
  ));
}
