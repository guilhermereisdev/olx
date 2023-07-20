import 'package:flutter/material.dart';

class BotaoCustomizado extends StatelessWidget {
  const BotaoCustomizado({
    super.key,
    required this.texto,
    this.corTexto = Colors.white,
    required this.onPressed,
  });

  final String texto;
  final Color corTexto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: corTexto,
          fontSize: 20,
        ),
      ),
    );
  }
}
