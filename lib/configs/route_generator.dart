import 'package:flutter/material.dart';

import '../enum/routes_names.dart';
import '../views/screens/login.dart';
import '../views/screens/anuncios.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoutes(RouteSettings settings) {
    final args = settings.arguments.toString();

    switch (settings.name) {
      case RoutesNames.anuncios:
        return MaterialPageRoute(builder: (_) => const Anuncios());
      case RoutesNames.login:
        return MaterialPageRoute(builder: (_) => const Login());
      default:
        _erroRota();
    }
    return null;
  }

  static Route<dynamic>? _erroRota() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Tela não encontrada!"),
        ),
        body: const Text("Tela não encontrada!"),
      );
    });
  }
}
