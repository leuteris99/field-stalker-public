import 'dart:convert';

class Package {
  int id;
  int ardId;
  int temp;
  int light;
  int humidity;
  DateTime timestamp;

  Package(
    this.id,
    this.ardId,
    this.temp,
    this.light,
    this.humidity,
    this.timestamp,
  );

  @override
  String toString() {
    return 'Package(id: $id, ardId: $ardId, temp: $temp, light: $light, humidity: $humidity, timestamp: $timestamp)';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ardId': ardId,
      'temp': temp,
      'light': light,
      'humidity': humidity,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Package.fromMap(Map<String, dynamic> map) {
    return Package(
      map['id'],
      map['ard_id'],
      map['temp'],
      map['light'],
      map['humidity'],
      DateTime.fromMillisecondsSinceEpoch(map['timestamp'].seconds * 1000),
    );
  }

  String toJson() => json.encode(toMap());

  factory Package.fromJson(String source) =>
      Package.fromMap(json.decode(source));
}
