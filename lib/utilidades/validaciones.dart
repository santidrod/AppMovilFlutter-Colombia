/// Clase que contiene validaciones

/// Lista de dominios de correo institucional
List<String> listaCorreoInstitucional = [
  'gob.bo',
  'edu.bo',
  'mil.bo',
  'int.bo',
  'academia.bo',
  'agro.bo',
  'arte.bo',
  'blog.bo',
  'bolivia.bo',
  'ciencia.bo',
  'cooperativa.bo',
  'democracia.bo',
  'deporte.bo',
  'ecologia.bo',
  'economia.bo',
  'empresa.bo',
  'indigena.bo',
  'industria.bo',
  'info.bo',
  'medicina.bo',
  'movimiento.bo',
  'musica.bo',
  'natural.bo',
  'nombre.bo',
  'noticias.bo',
  'patria.bo',
  'politica.bo',
  'profesional.bo',
  'plurinacional.bo',
  'pueblo.bo',
  'revista.bo',
  'salud.bo',
  'tecnologia.bo',
  'tksat.bo',
  'transporte.bo',
  'wiki.bo'
];

class Validar {
  /// RegEx pattern for validating email addresses.
  static Pattern emailPattern =
      r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$";
  static RegExp emailRegEx = RegExp(emailPattern);

  /// RegEx pattern for validating dates dd/MM/yyyy.
  static Pattern datePattern = r"^(0?[1-9]|[12][0-9]|3[01])[\/\-](0?[1-9]|1[012])[\/\-]\d{4}$";
  static RegExp dateRegEx = RegExp(datePattern);

  /// RegEx pattern for validating phone number
  static final phonePattern = RegExp("(^[6-7]{1})+[0-9]{7}");

  /// Validates an email address.
  static bool isEmail(String value) {
    return emailRegEx.hasMatch(value.trim());
  }

  /// Validates a date.
  static bool fecha(String value) {
    if (dateRegEx.hasMatch(value.trim())) {
      return true;
    }
    return false;
  }

  /// Validación de contraseña
  static bool contrasenia(String value) {
    // String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$';
    RegExp regExp = new RegExp(pattern);
    return regExp.hasMatch(value);
  }

  /// Campo requerido
  static String requiredField(String value, String message) {
    if (value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  /// validación de teléfono celular
  static bool telefono(String value) {
    if (phonePattern.hasMatch(value.trim())) {
      return true;
    }
    return false;
  }

  /// Validación de correo institucional
  static bool esInstitucional(String correo) {
    return listaCorreoInstitucional.where((element) => correo.contains(element)).length > 0;
  }
}
