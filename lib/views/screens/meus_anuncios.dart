import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/enum/routes_names.dart';
import 'package:olx/models/anuncio.dart';

import '../widgets/custom_item_anuncio.dart';

class MeusAnuncios extends StatefulWidget {
  const MeusAnuncios({super.key});

  @override
  State<MeusAnuncios> createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  String? _idUsuarioLogado;
  final _controller = StreamController<QuerySnapshot>.broadcast();

  _recuperarDadosUsuarioLogado() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;
    _idUsuarioLogado = usuarioLogado?.uid;
  }

  _adicionarListenerAnuncios() {
    _recuperarDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _removerAnuncio(String idAnuncio) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("meus_anuncios")
        .doc(_idUsuarioLogado)
        .collection("anuncios")
        .doc(idAnuncio)
        .delete()
        .then((_) async {
      await db.collection("anuncios").doc(idAnuncio).delete();
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    var carregandoDados = const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          Text("Carregando anúncios"),
        ],
      ),
    );

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
      body: StreamBuilder(
        stream: _controller.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return carregandoDados;
            case ConnectionState.waiting:
              return carregandoDados;
            case ConnectionState.active:
            case ConnectionState.done:
              if (snapshot.hasError) {
                const Text("Erro ao carregar dados");
              } else if (snapshot.data != null) {
                QuerySnapshot querySnapshot = snapshot.data!;
                return ListView.builder(
                  itemCount: querySnapshot.docs.length,
                  itemBuilder: (_, indice) {
                    List<DocumentSnapshot> anuncios =
                        querySnapshot.docs.toList();
                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    Anuncio anuncio =
                        Anuncio.fromDocumentSnapshot(documentSnapshot);

                    return ItemAnuncio(
                      anuncio: anuncio,
                      onPressedRemover: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Confirmar exclusão"),
                              content: const Text(
                                  "Deseja realmente excluir o anúncio?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    "Não",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await _removerAnuncio(anuncio.id);
                                    Future.microtask(
                                        () => Navigator.of(context).pop());
                                  },
                                  child: const Text(
                                    "Excluir",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }
              return Container();
          }
        },
      ),
    );
  }
}
