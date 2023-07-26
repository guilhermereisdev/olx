import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/views/widgets/custom_button.dart';
import 'package:olx/views/widgets/custom_input.dart';

import '../../enum/routes_names.dart';
import '../../exception/custom_exception.dart';
import '../../models/usuario.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _controllerNome = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  bool _cadastrar = false;
  String _mensagemErro = "";
  bool _errorContainerVisibility = false;
  bool _loadingVisibility = false;

  bool _validarCampos() {
    if (_controllerNome.text.trim().isNotEmpty) {
      if (_controllerEmail.text.trim().isNotEmpty) {
        if (_controllerSenha.text.trim().length > 7) {
          return true;
        } else {
          throw CustomException("A senha deve conter no mínimo 8 caracteres.");
        }
      } else {
        throw CustomException("Preencha o campo de e-mail.");
      }
    } else {
      throw CustomException("Preencha o campo de nome.");
    }
  }

  _exibirLoading(bool exibir) {
    setState(() {
      _loadingVisibility = exibir ? true : false;
    });
  }

  _exibirMensagemErro(bool exibir, {String mensagem = ""}) {
    setState(() {
      _mensagemErro = mensagem;
      _errorContainerVisibility = exibir ? true : false;
    });
  }

  Future<String?> _logarUsuario() async {
    Usuario usuario = Usuario();
    usuario.email = _controllerEmail.text;
    usuario.senha = _controllerSenha.text;

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      final usuarioLogado = await auth.signInWithEmailAndPassword(
        email: usuario.email,
        password: usuario.senha,
      );

      if (usuarioLogado.user?.uid != null) {
        return usuarioLogado.user?.uid;
      } else {
        throw CustomException("Usuário nulo.");
      }
    } on FirebaseAuthException catch (ex) {
      switch (ex.code) {
        case "user-disabled":
          throw CustomException(
              "Esse usuário está desabilitado e não pode utilizar a plataforma.");
        case "invalid-email":
          throw CustomException("Formato de e-mail inválido.");
        case "user-not-found":
          throw CustomException("Não há usuário relacionado a esse e-mail.");
        case "wrong-password":
          throw CustomException("Senha incorreta.");
        case "too-many-requests":
          throw CustomException(
              "Muitas tentativas incorretas de login.\nO acesso a essa conta foi temporariamente suspenso.\n\nVocê pode acessar sua conta imediatamente ao alterar sua senha na opção \"Esqueci a senha\" ou tentar novamente mais tarde.");
      }
    } catch (ex) {
      throw CustomException(ex.toString());
    }
    throw CustomException("Função de logar usuário não foi executada.");
  }

  Future<bool> _cadastrarUsuario() async {
    Usuario usuario = Usuario();
    usuario.nome = _controllerNome.text;
    usuario.email = _controllerEmail.text;
    usuario.senha = _controllerSenha.text;

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      FirebaseFirestore db = FirebaseFirestore.instance;
      await auth
          .createUserWithEmailAndPassword(
              email: usuario.email, password: usuario.senha)
          .then((firebaseUser) async => {
                await db
                    .collection("usuarios")
                    .doc(firebaseUser.user?.uid)
                    .set(usuario.toMap())
              });
      return Future.value(true);
    } on FirebaseAuthException catch (ex) {
      switch (ex.code) {
        case "email-already-in-use":
          throw CustomException(
              "Esse e-mail já está cadastrado. Tente entrar normalmente ou use a ferramenta de recuperar senha.");
        case "invalid-email":
          throw CustomException("Formato de e-mail inválido.");
        case "weak-password":
          throw CustomException("Use uma senha mais forte.");
      }
    } catch (ex) {
      throw CustomException(ex.toString());
    }
    return Future.value(false);
  }

  _redirecionaParaTelaInicialLogada(String? idUsuario) async {
    Navigator.pushNamedAndRemoveUntil(
      context,
      RoutesNames.anuncios,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Image.asset(
                    "images/logo.png",
                    width: 200,
                    height: 150,
                  ),
                ),
                if (_cadastrar)
                  InputCustomizado(
                    controller: _controllerNome,
                    hint: "nome",
                    keyboardType: TextInputType.name,
                  ),
                InputCustomizado(
                  controller: _controllerEmail,
                  hint: "e-mail",
                  keyboardType: TextInputType.emailAddress,
                ),
                InputCustomizado(
                  controller: _controllerSenha,
                  hint: "senha",
                  keyboardType: TextInputType.visiblePassword,
                  obscure: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Logar"),
                    Switch(
                      value: _cadastrar,
                      onChanged: (bool valor) {
                        setState(() {
                          _cadastrar = valor;
                        });
                      },
                    ),
                    const Text("Cadastrar"),
                  ],
                ),
                BotaoCustomizado(
                  texto: _cadastrar ? "Cadastrar e entrar" : "Entrar",
                  onPressed: () async {
                    _exibirLoading(true);
                    _exibirMensagemErro(false);
                    try {
                      if (_validarCampos()) {
                        if (_cadastrar) {
                          if (await _cadastrarUsuario()) {
                            await _redirecionaParaTelaInicialLogada(
                                await _logarUsuario());
                          }
                        } else {
                          await _redirecionaParaTelaInicialLogada(
                              await _logarUsuario());
                        }
                      }
                    } catch (ex) {
                      _exibirLoading(false);
                      _exibirMensagemErro(true, mensagem: ex.toString());
                    }
                  },
                ),
                Visibility(
                  visible: _loadingVisibility,
                  child: const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: _errorContainerVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      color: Colors.red,
                      child: Text(
                        _mensagemErro,
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
