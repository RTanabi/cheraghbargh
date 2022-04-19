import 'dart:convert' show json, jsonEncode;
import "package:cheraghbargh/src/screens/routes/sellers/seller_location.dart" show SellerLocation;
import 'package:http/http.dart' as http;

import 'package:flutter/foundation.dart' show Key, required;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart' show TabSelector;
import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;

class Sellers extends StatefulWidget {
  Sellers({Key key}) : super(key: key);

  @override
  _SellersState createState() => _SellersState();
}

class _SellersState extends State<Sellers> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  int cityDropdownIndex = 0;
  int stateDropdownIndex = 0;
  int cityId;
  int stateId;
  List<_SingleCity> cities = [];
  List<_SingleState> states = [];
  List<_SingleSalesMan> allSellers = [];

  @override
  void initState() {
    super.initState();
    getSellersRequest();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        key: _scaffoldKey,
        body: Builder(builder: (BuildContext context) {
          if (!isLoading) {
            return CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  expandedHeight: 70.0,
                  backgroundColor: Colors.white10,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    title: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "فروشندگان یدکی",
                        style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: "shabnam"),
                      ),
                    ),
                    titlePadding: EdgeInsets.only(top: 20),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Wrap(
                        direction: Axis.horizontal,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        children: <Widget>[
                          if (states.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("استان : "),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12, width: 0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButton<_SingleState>(
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                                    value: states[stateDropdownIndex],
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(height: 0),
                                    onChanged: (newValue) {
                                      int index = states.indexOf(newValue);
                                      setState(() {
                                        stateDropdownIndex = index;
                                        allSellers = [];
                                        cityDropdownIndex = 0;
                                        stateId = states[index].id;
                                        cities = [];
                                        cityId = null;
                                      });
                                      getSellersRequest();
                                    },
                                    items: states.map<DropdownMenuItem<_SingleState>>((value) {
                                      return DropdownMenuItem<_SingleState>(
                                        value: value,
                                        child: Text(value.stateName),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(width: 5, height: 80),
                          if (cities.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text("شهر : "),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black12, width: 0.6),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButton<_SingleCity>(
                                    style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                                    value: cities[cityDropdownIndex],
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    iconSize: 24,
                                    elevation: 16,
                                    underline: Container(height: 0),
                                    onChanged: (newValue) {
                                      int index = cities.indexOf(newValue);
                                      setState(() {
                                        cityDropdownIndex = index;
                                        cityId = cities[index].id;
                                      });
                                      getSellersRequest();
                                    },
                                    items: cities.map<DropdownMenuItem<_SingleCity>>((value) {
                                      return DropdownMenuItem<_SingleCity>(
                                        value: value,
                                        child: Text(value.cityName),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ]),
                ),
                SliverList(
                    delegate: SliverChildListDelegate(allSellers.isNotEmpty
                        ? allSellers.map((seller) => BuildSellers(seller: seller, cityName: cities[cityDropdownIndex].cityName)).toList()
                        : [Container(margin: EdgeInsets.only(top: 15), child: Center(child: Text("موردی یافت نشد !")))])),
                SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
              ],
            );
          }
          return CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: false,
                floating: false,
                expandedHeight: 70.0,
                backgroundColor: Colors.white10,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Container(
                    alignment: Alignment.center,
                    child: Text(
                      "فروشندگان",
                      style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: "shabnam"),
                    ),
                  ),
                  titlePadding: EdgeInsets.only(top: 20),
                ),
              ),
              SliverList(delegate: SliverChildListDelegate([Center(child: CircularProgressIndicator())])),
            ],
          );
        }),
        floatingActionButton: TabSelector(),
      ),
    );
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

  void getSellersRequest({int theStateID = -1}) async {
    setState(() => isLoading = true);
    theStateID = theStateID != -1 ? theStateID : stateId;
    if (states.isNotEmpty && theStateID != null) {
      final http.Response response = await http.post(
        "${DotEnv().env['DOMAIN']}/salesman/citysalesman/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'state_id': theStateID.toString(),
          'city_id': cityId != null ? cityId.toString() : "",
        }),
      );
      if (mounted) {
        if (response.statusCode == 200) {
          _SalesMenRequest parsedResponse = _SalesMenRequest.fromJson(json.decode(response.body));
          setState(() {
            cities = parsedResponse.cities;
            cityDropdownIndex = parsedResponse.cities.indexOf(parsedResponse.cities.where((city) => city.id == parsedResponse.cityID).first);
            cityId = parsedResponse.cityID;
            allSellers = parsedResponse.salesmen;
            isLoading = false;
          });
        } else if (response.statusCode == 422) {
          showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
          setState(() => isLoading = false);
        } else if (response.statusCode == 404) {
          showSnackBar("خطا در ارسال");
          setState(() => isLoading = false);
        } else {
          showSnackBar("خطا در ارتباط با سرور");
          setState(() => isLoading = false);
          throw Exception(response.statusCode);
        }
      }
      return Future.value();
    } else {
      await getStates() ? getSellersRequest() : throw Exception("network err : get sellers");
    }
    return Future.value();
  }

  Future<bool> getStates() async {
    final http.Response response = await http.post(
      "${DotEnv().env['DOMAIN']}/salesman/statesalesman/",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'state_id': stateId != null ? stateId.toString() : "",
      }),
    );
    if (mounted) {
      if (response.statusCode == 200) {
        _StateSalesMenRequest parsedResponse = _StateSalesMenRequest.fromJson(json.decode(response.body));
        setState(() {
          states = parsedResponse.states;
          stateId = parsedResponse.stateID;
          stateDropdownIndex = parsedResponse.states.indexOf(parsedResponse.states.where((state) => state.id == parsedResponse.stateID).first);
        });
        return true;
      } else if (response.statusCode == 422) {
        showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
        return false;
      } else if (response.statusCode == 404) {
        showSnackBar("خطا در ارسال");
        return false;
      } else {
        showSnackBar("خطا در ارتباط با سرور");
        throw Exception(response.statusCode);
      }
    }
    return false;
  }
}

class BuildSellers extends StatelessWidget {
  final _SingleSalesMan seller;
  final String cityName;
  const BuildSellers({Key key, @required this.seller, @required this.cityName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SellerLocation(
            address: seller.address,
            phone: seller.phone,
            lat: double.parse(seller.latitude),
            lng: double.parse(seller.longitude),
            text: seller.username,
          ),
        ),
      ),
      child: Container(
        height: 120,
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(16.0),
          image: DecorationImage(
            image: NetworkImage(seller.image != null && seller.image.isNotEmpty
                ? "${DotEnv().env['DOMAIN']}/media/${seller.image}"
                : "https://via.placeholder.com/300x100"),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black38, BlendMode.hardLight),
          ),
        ),
        child: Text(
          "${seller.username} - $cityName",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}

class _SalesMenRequest {
  final bool status;
  final int cityID;
  final String cityName;
  final List<_SingleSalesMan> salesmen;
  final List<_SingleCity> cities;

  _SalesMenRequest({@required this.status, this.cityID, this.cityName, this.salesmen, this.cities});

  factory _SalesMenRequest.fromJson(Map<String, dynamic> json) {
    return _SalesMenRequest(
      status: json['status'],
      cityID: json['city_id'],
      cityName: json['city_name'],
      salesmen: json['Message'] == null ? (json['Salesman'] as List).map((salesman) => _SingleSalesMan.fromJson(salesman)).toList() : [],
      cities: (json['Cities'] as List).map((city) => _SingleCity.fromJson(city)).toList(),
    );
  }
}

class _StateSalesMenRequest {
  final bool status;
  final int stateID;
  final String stateName;
  final List<_SingleCity> cities;
  final List<_SingleState> states;

  _StateSalesMenRequest({@required this.status, this.stateID, this.stateName, this.states, this.cities});

  factory _StateSalesMenRequest.fromJson(Map<String, dynamic> json) {
    return _StateSalesMenRequest(
      status: json['status'],
      stateID: json['state_id'],
      stateName: json['state_name'],
      cities: (json['CitiesList'] as List).map((city) => _SingleCity.fromJson(city)).toList(),
      states: (json['StatesList'] as List).map((state) => _SingleState.fromJson(state)).toList(),
    );
  }
}

class _SingleSalesMan {
  final String username;
  final String phone;
  final String latitude;
  final String longitude;
  final String image;
  final String userEmail;
  final String address;

  _SingleSalesMan({this.username, this.phone, this.latitude, this.longitude, this.image, this.userEmail, this.address});

  factory _SingleSalesMan.fromJson(Map<String, dynamic> json) {
    return _SingleSalesMan(
      username: json['Username'],
      phone: json['Phone'],
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      image: json['image'],
      userEmail: json['UserEmail'],
      address: json['Address'],
    );
  }
}

class _SingleCity {
  final int id;
  final String cityName;

  _SingleCity({this.id, this.cityName});

  factory _SingleCity.fromJson(Map<String, dynamic> json) {
    return _SingleCity(
      id: json['id'],
      cityName: json['cityname'],
    );
  }
}

class _SingleState {
  final int id;
  final String stateName;

  _SingleState({this.id, this.stateName});

  factory _SingleState.fromJson(Map<String, dynamic> json) {
    return _SingleState(
      id: json['id'],
      stateName: json['statename'],
    );
  }
}
