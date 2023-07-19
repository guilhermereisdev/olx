import 'package:flutter/material.dart';

class InputCustomizado extends StatefulWidget {
  const InputCustomizado(
      {super.key,
      required this.controller,
      required this.hint,
      this.obscure = false,
      this.autofocus = false,
      this.type = TextInputType.text});

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType type;

  @override
  State<InputCustomizado> createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado> {
  bool _passwordVisibility = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscure ? _passwordVisibility : false,
      autofocus: widget.autofocus,
      keyboardType: widget.type,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        suffixIcon: widget.type == TextInputType.visiblePassword
            ? IconButton(
                icon: Icon(_passwordVisibility
                    ? Icons.visibility
                    : Icons.visibility_off),
                onPressed: () {
                  setState(
                    () {
                      _passwordVisibility = !_passwordVisibility;
                    },
                  );
                },
              )
            : null,
      ),
    );
  }
}
