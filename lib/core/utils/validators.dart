abstract final class Validators {
  static final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final providerRucPattern = RegExp(r'^(10|15|17|20)[0-9]{9}$');
  static bool isEmail(String value) => emailPattern.hasMatch(value.trim());
  static bool isProviderRuc(String value) =>
      providerRucPattern.hasMatch(value.trim());
}
