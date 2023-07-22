import 'package:cloud_firestore/cloud_firestore.dart';

class Anuncio {
  late String id;
  late String estado;
  late String categoria;
  late String titulo;
  late String preco;
  late String telefone;
  late String descricao;
  late List<String> fotos;

  Anuncio() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    CollectionReference anuncios = db.collection("meus_anuncios");
    id = anuncios.doc().id;
    fotos = [];
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "estado": estado,
      "categoria": categoria,
      "titulo": titulo,
      "preco": preco,
      "telefone": telefone,
      "descricao": descricao,
      "fotos": fotos,
    };
  }
}
