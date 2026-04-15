class DateHelper {
  DateHelper._();

  static String compact(DateTime value) {
    final local = value.toLocal();
    return local.toString().substring(0, 16);
  }
}
