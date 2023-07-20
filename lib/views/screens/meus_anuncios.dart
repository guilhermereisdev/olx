import 'package:flutter/material.dart';
import 'package:olx/enum/routes_names.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({super.key});

  @override
  State<MeusAnuncios> createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meus anúncios"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesNames.novoAnuncio);
        },
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Container(),
    );
  }
}
