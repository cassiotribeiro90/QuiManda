class LocationEntity {
  final double latitude;
  final double longitude;
  final String? title;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.title,
  });

  Map<String, dynamic> toJson() => {
    'lat': latitude,
    'lng': longitude,
    'title': title,
  };
}
