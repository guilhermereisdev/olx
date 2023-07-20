import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/enum/routes_names.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = [];

  _escolhaMenuItem(String itemEscolhido) async {
    switch (itemEscolhido) {
      case "Meus anúncios":
        Navigator.pushNamed(context, RoutesNames.meusAnuncios);
        break;
      case "Entrar/Cadastrar":
        Navigator.pushNamed(context, RoutesNames.login);
        break;
      case "Deslogar":
        if (await _deslogarUsuario()) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RoutesNames.anuncios,
            (_) => false,
          );
        }
        break;
    }
  }

  Future _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut();
    if (auth.currentUser == null) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  _montarEExibirMenu() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    if (usuarioLogado == null) {
      itensMenu = ["Entrar/Cadastrar"];
    } else {
      itensMenu = ["Meus anúncios", "Deslogar"];
    }
  }

  @override
  void initState() {
    super.initState();
    _montarEExibirMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OLX"),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return itensMenu.map((item) {
                return PopupMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList();
            },
            onSelected: _escolhaMenuItem,
          ),
        ],
      ),
      body: Container(
        child: const Text("anúncios"),
      ),
    );
  }
}
