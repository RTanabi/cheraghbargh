import 'package:cheraghbargh/src/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:user_location/user_location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChooseLocation extends StatefulWidget {
  final ProfileViewModel vm;

  const ChooseLocation({Key key, @required this.vm}) : super(key: key);
  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  final GlobalKey<ScaffoldState> _scaffoldKeyMap = new GlobalKey<ScaffoldState>();
  MapController mapController = MapController();
  LatLng latLang = LatLng(35.6936, 51.3842);
  LatLng selectedPos;
  UserLocationOptions userLocationOptions;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    if (widget.vm.user.location != null && widget.vm.user.location.latitude > 0) {
      setState(() => selectedPos = widget.vm.user.location);
    }
  }

  @override
  void dispose() {
    // widget.vm.changeLocationDispatch(selectedPos);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // You can use the userLocationOptions object to change the properties
    // of UserLocationOptions in runtime
    userLocationOptions = UserLocationOptions(
      context: context,
      mapController: mapController,
      markers: markers,
      onLocationUpdate: (LatLng pos) => setState(() {
        latLang = pos;
        selectedPos = selectedPos == null && widget.vm.user.location == null ? pos : selectedPos;
      }),
      updateMapLocationOnPositionChange: false,
      showMoveToCurrentLocationFloatingActionButton: true,
      zoomToCurrentLocationOnLoad: true,
      // fabBottom: 80,
      // fabRight: 30,
      verbose: false,
    );
    return Scaffold(
      key: _scaffoldKeyMap,
      appBar: AppBar(
        title: Text("انتخاب موقعیت مکانی"),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            options: MapOptions(
              center: widget.vm.user.location != null && widget.vm.user.location.latitude > 0 ? widget.vm.user.location : latLang,
              zoom: 15.0,
              onTap: (position) => setState(() => selectedPos = position),
              plugins: [
                UserLocationPlugin(),
              ],
            ),
            layers: [
              TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                  markers: markers +
                      [
                        Marker(
                          width: 40,
                          height: 40,
                          anchorPos: AnchorPos.align(AnchorAlign.top),
                          point: selectedPos,
                          builder: (ctx) => Container(
                            child: Stack(
                              alignment: Alignment.center,
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Icon(
                                  Icons.location_on,
                                  color: Colors.red[600],
                                  size: 42,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
              userLocationOptions,
            ],
            mapController: mapController,
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
      floatingActionButton: RaisedButton(
        elevation: 0,
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.all(10.0),
        shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
        splashColor: Colors.white54,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("ذخیره موقعیت", style: TextStyle(color: Colors.white)),
              SizedBox(width: 10),
              SizedBox(
                child: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                height: 20.0,
                width: 20.0,
              )
            ],
          ),
        ),
        onPressed: handleClickSubmit,
      ),
    );
  }

  _launchURL() async {
    String url = "geo:${selectedPos.latitude},${selectedPos.longitude}?q=${selectedPos.latitude},${selectedPos.longitude}(Label,Name)";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void handleClickSubmit() async {
    final http.Response response = await http.post(
      "${DotEnv().env['DOMAIN']}/salesman/setlocation/",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "token": widget.vm.user.token,
        "latitude": selectedPos.latitude.toString(),
        "longitude": selectedPos.longitude.toString()
      }),
    );

    if (response.statusCode == 200) {
      widget.vm.changeLocationDispatch(selectedPos);
      if (Navigator.of(context).canPop()) {
        Navigator.popUntil(context, ModalRoute.withName('/'));
      }
    } else if (response.statusCode == 422) {
      showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
    } else if (response.statusCode == 404) {
      showSnackBar("خطا در ارسال");
    } else {
      showSnackBar("خطا در ارتباط با سرور");
      throw Exception(response.statusCode);
    }
  }

  void showSnackBar(String text) {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(text, style: Theme.of(context).textTheme.headline6),
        ),
      );
    }
  }
}
