import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:olx/telas/home.dart';
import 'package:olx/temas/temas.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
    title: "OLX",
    home: const Home(),
    theme: themeData,
    debugShowCheckedModeBanner: false,
  ));
}
