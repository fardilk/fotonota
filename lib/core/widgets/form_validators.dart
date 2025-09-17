class FormValidators {
  static String? nonEmpty(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;
  static String? match(String? v, String other, [String? message]) => (v == null || v != other) ? (message ?? 'Does not match') : null;
}
