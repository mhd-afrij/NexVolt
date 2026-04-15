class Formatters {
  Formatters._();

  static String miles(double value) => '${value.toStringAsFixed(1)} mi';
  static String battery(int percent) => 'Battery: $percent%';
}
