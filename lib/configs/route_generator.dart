import 'package:flutter/material.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/views/screens/detalhes_anuncio.dart';
import 'package:olx/views/screens/meus_anuncios.dart';
import 'package:olx/views/screens/novo_anuncio.dart';

import '../enum/routes_names.dart';
import '../views/screens/login.dart';
import '../views/screens/anuncios.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoutes(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RoutesNames.anuncios:
        return MaterialPageRoute(builder: (_) => const Anuncios());
      case RoutesNames.login:
        return MaterialPageRoute(builder: (_) => const Login());
      case RoutesNames.meusAnuncios:
        return MaterialPageRoute(builder: (_) => const MeusAnuncios());
      case RoutesNames.novoAnuncio:
        return MaterialPageRoute(builder: (_) => const NovoAnuncio());
      case RoutesNames.detalhesAnuncio:
        return MaterialPageRoute(
            builder: (_) => DetalhesAnuncio(args as Anuncio?));
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
