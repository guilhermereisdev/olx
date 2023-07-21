import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputCustomizado extends StatefulWidget {
  const InputCustomizado(
      {super.key,
      required this.controller,
      required this.hint,
      this.obscure = false,
      this.autofocus = false,
      this.keyboardType = TextInputType.text,
      this.inputFormatters = const [],
      this.maxLines = 1,
      this.validator});

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int? maxLines;
  final FormFieldValidator<String>? validator;

  @override
  State<InputCustomizado> createState() => _InputCustomizadoState();
}

class _InputCustomizadoState extends State<InputCustomizado> {
  bool _passwordVisibility = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscure ? _passwordVisibility : false,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      validator: widget.validator,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        suffixIcon: widget.keyboardType == TextInputType.visiblePassword
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
