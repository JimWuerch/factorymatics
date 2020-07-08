extension StringExtensions on String {
  /// Strip the leading classname from enum.toString()
  String stripClassName() {
      return substring(indexOf('.') + 1);
  }

  bool isDigit(int idx) => (codeUnitAt(idx) ^ 0x30) <= 9;
}