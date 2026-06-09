class GuideParser {
  static ({String serie, String number}) parse(String input) {
    final trimmed = input.trim().toUpperCase();
    final regex = RegExp(r'^([A-Z]+)(\d+)$');
    final match = regex.firstMatch(trimmed);
    if (match != null) {
      return (serie: match.group(1)!, number: match.group(2)!);
    }
    return (serie: '', number: trimmed);
  }

  static String formatGuide(String serie, String number) {
    if (serie.isEmpty) return number;
    return '$serie$number';
  }

  static bool isValid(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return false;
    return RegExp(r'^[A-Za-z]*\d+$').hasMatch(trimmed);
  }
}