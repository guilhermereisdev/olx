import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/enum/routes_names.dart';
import 'package:olx/utils/configuracoes.dart';
import 'package:olx/views/widgets/custom_item_anuncio.dart';

import '../../models/anuncio.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({super.key});

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = [];
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String? _itemSelecionadoEstado;
  String? _itemSelecionadoCategoria;
  List<DropdownMenuItem<String>>? _listaItensDropEstados = [];
  List<DropdownMenuItem<String>>? _listaItensDropCategorias = [];

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
          Future.microtask(() => Navigator.pushNamedAndRemoveUntil(
                context,
                RoutesNames.anuncios,
                (_) => false,
              ));
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

  _carregarItensDropdown() {
    _listaItensDropCategorias = Configuracoes.getCategorias();
    _listaItensDropEstados = Configuracoes.getRegioes();
  }

  _filtrarAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    Query query = db.collection("anuncios");
    if (_itemSelecionadoEstado != null) {
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    }
    if (_itemSelecionadoCategoria != null) {
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
    }

    Stream<QuerySnapshot> stream = query.snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  _adicionarListenerAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db.collection("anuncios").snapshots();
    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _montarEExibirMenu();
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Colors.purple,
                        value: _itemSelecionadoEstado,
                        items: _listaItensDropEstados,
                        onChanged: (estado) {
                          setState(() {
                            _itemSelecionadoEstado = estado;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey.shade200,
                  width: 2,
                  height: 35,
                ),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: Center(
                      child: DropdownButton(
                        iconEnabledColor: Colors.purple,
                        value: _itemSelecionadoCategoria,
                        items: _listaItensDropCategorias,
                        onChanged: (categoria) {
                          setState(() {
                            _itemSelecionadoCategoria = categoria;
                            _filtrarAnuncios();
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            StreamBuilder(
              stream: _controller.stream,
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return carregandoDados;
                  case ConnectionState.waiting:
                    return carregandoDados;
                  case ConnectionState.active:
                  case ConnectionState.done:
                    QuerySnapshot querySnapshot = snapshot.data!;
                    if (querySnapshot.docs.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        child: const Text(
                          "Nenhum anúncio! :(",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ListView.builder(
                          itemBuilder: (_, indice) {
                            List<DocumentSnapshot> anuncios =
                                querySnapshot.docs.toList();
                            DocumentSnapshot documentSnapshot =
                                anuncios[indice];
                            Anuncio anuncio =
                                Anuncio.fromDocumentSnapshot(documentSnapshot);

                            return ItemAnuncio(
                              anuncio: anuncio,
                              onTapItem: () {},
                            );
                          },
                          itemCount: querySnapshot.docs.length,
                        ),
                      );
                    }
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
