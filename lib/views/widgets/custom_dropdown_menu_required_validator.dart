import 'package:form_field_validator/form_field_validator.dart';

class CustomDropdownMenuRequiredValidator extends FieldValidator<String?> {
  CustomDropdownMenuRequiredValidator({required String errorText}) : super(errorText);

  @override
  String? call(Object? value) {
    return isValid(value) ? null : errorText;
  }

  @override
  bool isValid(Object? value) {
    return value != null ? true : false;
  }
}