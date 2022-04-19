import 'dart:convert' as jSON;
import 'package:meta/meta.dart' show immutable, required;
import 'package:latlong/latlong.dart' show LatLng;

@immutable
class User {
  final String name;
  final String address;
  final String phone;
  final int cityID;
  final int stateID;
  final String avatarUrl;
  final LatLng location;
  final String token;

  User({this.name, this.address = "", this.phone = "", this.stateID, this.cityID, this.avatarUrl = "", this.location, @required this.token});

  User copyWith({name, address, phone, stateID, cityID, avatarUrl, location, token}) {
    return User(
        name: name ?? this.name,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        address: address ?? this.address,
        phone: phone ?? this.phone,
        stateID: stateID ?? this.stateID,
        cityID: cityID ?? this.cityID,
        location: location ?? this.location,
        token: token ?? this.token);
  }

  static User fromJson(dynamic json) {
    return json != null
        ? User(
            name: json["name"],
            address: json["address"],
            phone: json["phone"],
            stateID: json["stateID"],
            cityID: json["cityID"],
            avatarUrl: json["avatarUrl"],
            location: json["location"] != null
                ? new LatLng(double.parse(jSON.jsonDecode(json["location"])["lat"]), double.parse(jSON.jsonDecode(json["location"])["lng"]))
                : null,
            token: json["token"],
          )
        : User(token: "");
  }

  dynamic toJson() {
    return {
      "name": name,
      "address": address,
      "phone": phone,
      "stateID": stateID,
      "cityID": cityID,
      "avatarUrl": avatarUrl,
      "location": location != null ? '''{"lat": "${location.latitude}", "lng": "${location.longitude}"}''' : null,
      "token": token,
    };
  }
}
