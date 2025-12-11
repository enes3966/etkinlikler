class EventModel {
  final int id;
  final String title;
  final String? description;
  final DateTime dateTime;
  final double? latitude;
  final double? longitude;
  final int organizerId;
  final String? organizerName;

  EventModel({
    required this.id,
    required this.title,
    this.description,
    required this.dateTime,
    this.latitude,
    this.longitude,
    required this.organizerId,
    this.organizerName,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      dateTime: DateTime.parse(json['date_time'] as String),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      organizerId: json['organizer_id'] as int,
      organizerName: json['organizer']?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date_time': dateTime.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'organizer_id': organizerId,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
    };
  }
}

