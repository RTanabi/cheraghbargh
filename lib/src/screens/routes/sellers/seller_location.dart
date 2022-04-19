import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerLocation extends StatelessWidget {
  final double lat;
  final double lng;
  final String address;
  final String phone;
  final String text;
  const SellerLocation({Key key, @required this.address, @required this.phone, this.lat = 0.0, this.lng = 0.0, @required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(text, style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            options: MapOptions(
              center: LatLng(lat, lng),
              zoom: 15.0,
            ),
            layers: [
              TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),
                    builder: (ctx) => Container(
                      child: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Positioned(
                            top: -110,
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.70,
                                height: 90,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      address ?? "",
                                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                    ),
                                    Text(
                                      phone ?? "",
                                      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Marker(
                    width: 40,
                    height: 40,
                    point: LatLng(lat, lng),
                    builder: (ctx) => Container(
                      child: Stack(
                        alignment: Alignment.center,
                        overflow: Overflow.visible,
                        children: <Widget>[
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(500)),
                              color: Theme.of(context).primaryColor,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            left: 20,
            child: RawMaterialButton(
              onPressed: _launchURL,
              elevation: 2.0,
              fillColor: Colors.white70,
              child: Icon(Icons.share, color: Theme.of(context).primaryColor, size: 35.0),
              padding: EdgeInsets.all(15.0),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
      floatingActionButton: TabSelector(),
    );
  }

  _launchURL() async {
    String url = "geo:$lat,$lng?q=$lat,$lng(Label,Name)";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
