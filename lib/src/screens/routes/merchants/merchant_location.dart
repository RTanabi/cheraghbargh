import 'dart:async';
import 'dart:io';
import 'package:cheraghbargh/src/components/marquee_text.dart';
import 'package:flutter/foundation.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart';
import 'package:cheraghbargh/src/screens/routes/merchants/pdf_screen_route.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class MerchantLocation extends StatefulWidget {
  final double lat;
  final double lng;
  final String address;
  final String name;
  final String phone;
  final String pdfUrl;
  const MerchantLocation({Key key, this.lat, this.lng, this.address, this.phone, this.pdfUrl, this.name}) : super(key: key);

  @override
  _MerchantLocationState createState() => _MerchantLocationState();
}

class _MerchantLocationState extends State<MerchantLocation> {
  String pathPDF = "";
  LatLng latLang;

  @override
  void initState() {
    super.initState();
    if (mounted) setState(() => latLang = LatLng(widget.lat, widget.lng));
    if (widget.pdfUrl != null && widget.pdfUrl.isNotEmpty && widget.pdfUrl.contains(".pdf")) {
      createFileOfPdfUrl().then((f) {
        if (mounted) {
          setState(() => pathPDF = f.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (latLang != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.name, style: Theme.of(context).textTheme.headline6.copyWith(color: Colors.white)),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            FlutterMap(
              options: MapOptions(
                center: latLang,
                zoom: 14.75,
              ),
              layers: [
                TileLayerOptions(urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", subdomains: ['a', 'b', 'c']),
                MarkerLayerOptions(
                  markers: [
                    Marker(
                      point: latLang,
                      width: MediaQuery.of(context).size.width * .75,
                      anchorPos: AnchorPos.align(AnchorAlign.top),
                      height: 120,
                      builder: (ctx) => Transform.translate(
                        offset: const Offset(0.0, -40.0),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MarqueeWidget(
                                  animationDuration: Duration(seconds: 8),
                                  backDuration: Duration(seconds: 3),
                                  child: Text(
                                    widget.address,
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  widget.phone ?? widget.name,
                                  style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                ),
                              ),
                              if (widget.pdfUrl != null && widget.pdfUrl.isNotEmpty && widget.pdfUrl.contains(".pdf"))
                                RaisedButton(
                                  elevation: 0,
                                  color: Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.all(10.0),
                                  splashColor: Colors.white54,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "مشاهده  pdf محصولات",
                                        style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),
                                      ),
                                      SizedBox(width: 10),
                                      if (pathPDF.isEmpty)
                                        SizedBox(
                                          child: CircularProgressIndicator(backgroundColor: Colors.white),
                                          height: 20.0,
                                          width: 20.0,
                                        ),
                                      if (pathPDF.isNotEmpty)
                                        SizedBox(
                                          child: Icon(Icons.picture_as_pdf, color: Colors.white),
                                          height: 20.0,
                                          width: 20.0,
                                        )
                                    ],
                                  ),
                                  onPressed: () => pathPDF.isNotEmpty
                                      ? Navigator.push(context, MaterialPageRoute(builder: (context) => PDFScreen(pathPDF)))
                                      : showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            content: Text("در حال دریافت pdf", style: Theme.of(context).textTheme.headline6),
                                          ),
                                        ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Marker(
                      width: 40,
                      height: 40,
                      anchorPos: AnchorPos.align(AnchorAlign.center),
                      point: latLang,
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
                                // size: 25,
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
    } else {
      return Container();
    }
  }

  _launchURL() async {
    String url = "geo:${latLang.latitude},${latLang.longitude}?q=${latLang.latitude},${latLang.longitude}(Label,Name)";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<File> createFileOfPdfUrl() async {
    try {
      final url = widget.pdfUrl;
      final filename = url.substring(url.lastIndexOf("/") + 1);
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      String dir = (await getApplicationDocumentsDirectory()).path;
      File file = new File('$dir/$filename');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {}
    return Future.value();
  }
}
