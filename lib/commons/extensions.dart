extension StringExtension on String {
  String limpiarNumeroParaFormateo() {
    return replaceAll(RegExp(r'[,.]'), '');
  }
}