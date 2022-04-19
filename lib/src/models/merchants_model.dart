import 'package:meta/meta.dart' show immutable;

@immutable
class SingleMerchantModel {
  final String name;
  final String phone;
  final String photo;
  final String latitude;
  final String longitude;
  final String pdfUrl;
  final String address;

  SingleMerchantModel({this.phone, this.photo, this.latitude, this.longitude, this.pdfUrl, this.address, this.name});

  SingleMerchantModel copyWith({name, phone, photo, latitude, longitude, pdfUrl, address}) {
    return SingleMerchantModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      address: address ?? this.address,
    );
  }

  static SingleMerchantModel fromJson(dynamic json) {
    return json != null
        ? SingleMerchantModel(
            name: json["name"],
            phone: json["phone"],
            photo: json["photo"],
            latitude: json["latitude"],
            longitude: json["longitude"],
            pdfUrl: json["pdfUrl"],
            address: json["address"],
          )
        : null;
  }

  dynamic toJson() {
    return {
      "name": name,
      "phone": phone,
      "photo": photo,
      "latitude": latitude,
      "longitude": longitude,
      "pdfUrl": pdfUrl,
      "address": address,
    };
  }
}
