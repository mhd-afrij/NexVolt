class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperature,
    required this.summary,
    required this.fetchedAt,
  });

  final double temperature;
  final String summary;
  final DateTime fetchedAt;
}
