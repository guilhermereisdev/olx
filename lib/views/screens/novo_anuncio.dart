import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:image_picker/image_picker.dart';
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
  TextEditingController tituloController = TextEditingController();
  TextEditingController precoController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    _carregarItensDropdown();
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
                    controller: tituloController,
                    hint: "Título",
                    validator: requiredValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    controller: precoController,
                    keyboardType: TextInputType.number,
                    hint: "Preço",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter()
                    ],
                    validator: requiredValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    controller: telefoneController,
                    keyboardType: TextInputType.phone,
                    hint: "Telefone",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    validator: requiredValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InputCustomizado(
                    controller: descricaoController,
                    hint: "Descrição (até 200 caracteres)",
                    maxLines: null,
                    validator: descricaoValidator,
                  ),
                ),
                BotaoCustomizado(
                  texto: "Cadastrar anúncio",
                  onPressed: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {}
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
