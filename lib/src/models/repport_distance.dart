// ignore_for_file: dead_code

class RepportDistance {
  RepportDistance({
    required this.description,
    required this.startKm,
    required this.endKm,
    required this.distance,
    this.date,
  });

  final String description;
  final int startKm;
  final int endKm;
  final int distance;
  final String? date;

   int? get startOdometer {
    return double.tryParse((startKm / 1000).toString())!
        .toInt();
      return 0;
  }
   int? get endOdometer {
    return double.tryParse((endKm / 1000).toString())!
        .toInt();
      return 0;
  }

int? get getdistanceTraveled {
    return double.tryParse((distance / 1000).toString())!
        .toInt();
      return 0;
  }
  factory RepportDistance.fromJson(Map<String, dynamic> json) => RepportDistance(
        description: json["description"],
        startKm: json["start_km"],
        endKm: json["end_km"],
        distance: json["distance"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "start_km": startKm,
        "end_km": endKm,
        "distance": distance,
      };
}
