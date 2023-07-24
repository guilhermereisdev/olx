import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/models/anuncio.dart';
import 'package:olx/views/widgets/custom_dropdown_menu_required_validator.dart';
import 'package:olx/views/widgets/custom_input.dart';

import '../widgets/custom_button.dart';

class NovoAnuncio extends StatefulWidget {
  const NovoAnuncio({super.key});

  @override
  State<NovoAnuncio> createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final _formKey = GlobalKey<FormState>();
  final List<File> _listaImagens = [];
  final List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  String? _itemSelecionadoEstado;
  final List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  String? _itemSelecionadoCategoria;
  late Anuncio _anuncio;
  late BuildContext _dialogcontext;

  // regras de validação
  final dropdownRequiredValidator =
      CustomDropdownMenuRequiredValidator(errorText: "Campo obrigatório");
  final requiredValidator = RequiredValidator(errorText: "Campo obrigatório");
  final descricaoValidator = MultiValidator([
    RequiredValidator(errorText: "Campo obrigatório"),
    MaxLengthValidator(200, errorText: "Máximo de 200 caracteres"),
  ]);

  _selecionarImagemGaleria() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagemSelecionada =
        await picker.pickImage(source: ImageSource.gallery);

    if (imagemSelecionada != null) {
      setState(() {
        _listaImagens.add(File(imagemSelecionada.path));
      });
    }
  }

  _carregarItensDropdown() {
    var categorias = <Map<String, String>>[
      {'categoria': 'Imóvel', 'id': "imovel"},
      {'categoria': 'Automóvel', 'id': "automovel"},
      {'categoria': 'Moda', 'id': "moda"},
      {'categoria': 'Eletrônico', 'id': "eletronico"},
      {'categoria': 'Esportes', 'id': "esportes"}
    ];

    _listaItensDropCategorias.addAll(categorias.map((value) {
      return DropdownMenuItem<String>(
          value: value['id'], child: Text(value['categoria']!));
    }).toList());

    for (var estado in Estados.listaEstados) {
      _listaItensDropEstados.add(DropdownMenuItem(
        value: estado,
        child: Text(estado),
      ));
    }
  }

  Future _uploadImagens() async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();

    for (var imagem in _listaImagens) {
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo =
          pastaRaiz.child("meus_anuncios").child(_anuncio.id).child(nomeImagem);

      UploadTask uploadTask = arquivo.putFile(imagem);

      await uploadTask.then((TaskSnapshot taskSnapshot) async {
        String url = await taskSnapshot.ref.getDownloadURL();
        _anuncio.fotos.add(url);
      });
    }
  }

  _salvarAnuncio() async {
    _abrirDialog(_dialogcontext);
    await _uploadImagens();
    FirebaseAuth auth = FirebaseAuth.instance;
    User? usuarioLogado = auth.currentUser;

    FirebaseFirestore db = FirebaseFirestore.instance;
    await db
        .collection("meus_anuncios")
        .doc(usuarioLogado?.uid)
        .collection("anuncios")
        .doc(_anuncio.id)
        .set(_anuncio.toMap())
        .then((_) {
      Navigator.pop(_dialogcontext);
      Navigator.pop(context);
    });
  }

  _abrirDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Salvando"),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
    _anuncio = Anuncio();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // área de imagens
                FormField<List>(
                  builder: (state) {
                    return Column(
                      children: [
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _listaImagens.length + 1,
                            itemBuilder: (context, indice) {
                              if (indice == _listaImagens.length) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      _selecionarImagemGaleria();
                                    },
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade400,
                                      radius: 50,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_a_photo,
                                            size: 40,
                                            color: Colors.grey.shade100,
                                          ),
                                          Text(
                                            "Adicionar",
                                            style: TextStyle(
                                              color: Colors.grey.shade100,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (_listaImagens.isNotEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Image.file(_listaImagens[indice]),
                                              TextButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _listaImagens
                                                        .removeAt(indice);
                                                    Navigator.of(context).pop();
                                                  });
                                                },
                                                child: const Text(
                                                  "Excluir",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage:
                                          FileImage(_listaImagens[indice]),
                                      child: Container(
                                        color: const Color.fromRGBO(
                                          255,
                                          255,
                                          255,
                                          0.3,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return Container();
                            },
                          ),
                        ),
                        if (state.hasError)
                          Text(
                            "[${state.errorText}]",
                            style: const TextStyle(color: Colors.red),
                          )
                      ],
                    );
                  },
                  initialValue: _listaImagens,
                  validator: (imagens) {
                    if (imagens != null && imagens.isEmpty) {
                      return "É necessário selecionar uma imagem";
                    }
                    return null;
                  },
                ),
                // menus dropdown
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 4,
                          top: 16,
                          bottom: 16,
                        ),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoEstado,
                          hint: const Text("Estado"),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          items: _listaItensDropEstados,
                          onChanged: (valor) {
                            setState(() {
                              _itemSelecionadoEstado = valor;
                            });
                          },
                          onSaved: (estado) {
                            estado != null ? _anuncio.estado = estado : null;
                          },
                          validator: dropdownRequiredValidator,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 4,
                          top: 16,
                          bottom: 16,
                        ),
                        child: DropdownButtonFormField(
                          value: _itemSelecionadoCategoria,
                          hint: const Text("Categoria"),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                          items: _listaItensDropCategorias,
                          onChanged: (valor) {
                            setState(() {
                              _itemSelecionadoCategoria = valor;
                            });
                          },
                          onSaved: (categoria) {
                            categoria != null
                                ? _anuncio.categoria = categoria
                                : null;
                          },
                          validator: dropdownRequiredValidator,
                        ),
                      ),
                    ),
                  ],
                ),
                // caixas de texto e botões
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    hint: "Título",
                    validator: requiredValidator,
                    onSaved: (titulo) {
                      titulo != null ? _anuncio.titulo = titulo : null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    keyboardType: TextInputType.number,
                    hint: "Preço",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter()
                    ],
                    validator: requiredValidator,
                    onSaved: (preco) {
                      preco != null ? _anuncio.preco = preco : null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    keyboardType: TextInputType.phone,
                    hint: "Telefone",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: requiredValidator,
                    onSaved: (telefone) {
                      telefone != null ? _anuncio.telefone = telefone : null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    hint: "Descrição (até 200 caracteres)",
                    maxLines: null,
                    validator: descricaoValidator,
                    onSaved: (descricao) {
                      descricao != null ? _anuncio.descricao = descricao : null;
                    },
                  ),
                ),
                BotaoCustomizado(
                  texto: "Cadastrar anúncio",
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      // salva os campos
                      _formKey.currentState?.save();
                      // configura dialog context
                      _dialogcontext = context;
                      // salva o anúncio
                      _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
