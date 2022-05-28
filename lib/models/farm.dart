import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farm_location_app/models/region.dart';

class FarmLocation {
  final double latitude;
  final double longtude;

  const FarmLocation({required this.latitude, required this.longtude});
}

class Farm {
  String _id;
  Region _region;
  String _name;
  FarmLocation _location;
  Farm copy() {
    return Farm(
      id: _id,
      region: _region,
      name: _name,
      locationCoordinate: _location,
    );
  }

  Farm(
      {required String id,
      required Region region,
      required String name,
      required FarmLocation locationCoordinate})
      : _id = id,
        _region = region,
        _name = name,
        _location = locationCoordinate;

  Farm.fromNetwork(Map<String, dynamic> data)
      : _id = data['id'],
        _region = Region(
            id: data['region_id'], name: data['region_name'], cmtNum: null),
        _name = data['name'],
        _location = FarmLocation(
            latitude: data['location']['lat'] as double,
            longtude: data['location']['lng'] as double);

  Farm copyWith({
    required String id,
    required Region region,
    required String name,
    required FarmLocation location,
  }) {
    return Farm(
      id: id,
      region: region,
      name: name,
      locationCoordinate: location,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': _id,
        'name': _name,
        'location': {
          'lat': _location.latitude,
          'lng': _location.longtude,
        },
        'region_id': _region.getId,
        'region_name': _region.getName,
        'timestamp': Timestamp.now(),
      };

  String get getId => _id;

  set setId(String id) => _id = id;

  Region get getRegion => _region;

  set setRegion(Region region) => _region = region;

  String get getName => _name;

  set setName(String name) => _name = name;

  FarmLocation get getLocationCrd => _location;

  set setLocationCrd(FarmLocation location) => _location = location;
}
