import 'package:cheraghbargh/src/screens/profile.dart' show ProfileViewModel, SetterGetterInt;
import 'package:cheraghbargh/src/screens/routes/profile/choose_location.dart' show ChooseLocation;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;
import 'package:latlong/latlong.dart' show LatLng;
import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonDecode, jsonEncode;

class ProfileForm extends StatefulWidget {
  final ProfileViewModel vm;
  final Function(String) showSnackBar;
  final TextEditingController profileNameController;
  final TextEditingController profileAddressController;
  final SetterGetterInt cityID;
  final SetterGetterInt stateID;
  final superContext;
  const ProfileForm({
    Key key,
    this.vm,
    this.superContext,
    @required this.showSnackBar,
    @required this.profileNameController,
    @required this.profileAddressController,
    @required this.cityID,
    @required this.stateID,
  }) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  bool isLoading = true;
  int cityDropdownIndex = 0;
  int stateDropdownIndex = 0;
  int cityId;
  int stateId;
  List<_SingleCity> cities = [];
  List<_SingleState> states = [];

  @override
  void initState() {
    super.initState();
    checkToken(widget.vm);
    getSellersRequest(theStateID: widget.vm.user.stateID, theCityID: widget.vm.user.cityID);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "نام یدکی : ",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: widget.profileNameController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: widget.vm.user.name,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "توضیحات : ",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  controller: widget.profileAddressController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: widget.vm.user.address,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "تلفن : ",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 7,
                child: TextField(
                  readOnly: true,
                  enabled: false,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: widget.vm.user.phone,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "استان/شهر : ",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 7,
                child: Wrap(
                  direction: Axis.horizontal,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.start,
                  children: <Widget>[
                    if (isLoading) CircularProgressIndicator(),
                    if (states.isNotEmpty && isLoading != true)
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<_SingleState>(
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
                          value: states[stateDropdownIndex],
                          icon: Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          underline: Container(height: 0),
                          onChanged: (newValue) {
                            int index = states.indexOf(newValue);
                            setState(() {
                              stateDropdownIndex = index;
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
                    SizedBox(width: 5, height: 60),
                    if (states.isNotEmpty && cities.isNotEmpty && isLoading != true)
                      Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12, width: 0.6),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButton<_SingleCity>(
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
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
                            widget.cityID.id = cities[index].id;
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
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(
                  "لوکیشن : ",
                  style: Theme.of(context).textTheme.bodyText1,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 6,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        color: Theme.of(context).primaryColor,
                      ),
                      child: new IconButton(
                        padding: EdgeInsets.all(0),
                        icon: Icon(Icons.location_on, size: 20),
                        color: Colors.white,
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChooseLocation(vm: widget.vm))),
                      ),
                    ),
                    SizedBox(width: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(widget.vm.user.location != null && widget.vm.user.location.longitude > 0 ? "انتخاب شده" : "انتخاب"),
                    )
                  ],
                ),
              ),
              Expanded(flex: 3, child: Container())
            ],
          ),
        ],
      ),
    );
  }

  void checkToken(ProfileViewModel vm) async {
    if (vm.user.token.isNotEmpty) {
      final http.Response response = await http.post(
        "${DotEnv().env['DOMAIN']}/salesman/getsalesman/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'token': vm.user.token,
        }),
      );

      if (response.statusCode == 200) {
        _CheckTokenRequest parsedResponse = _CheckTokenRequest.fromJson(json.decode(response.body));
        var theUser = parsedResponse.salesMan[0];
        vm.userAlterProfileAction(
          theUser.userName,
          theUser.lat != "0.000000" ? new LatLng(double.parse(theUser.lat), double.parse(theUser.lng)) : null,
          theUser.address,
          "0" + theUser.phone,
          theUser.stateID,
          theUser.stateID != null && theUser.stateID.isFinite ? theUser.cityID : null,
          theUser.image.isNotEmpty
              ? theUser.image.contains("salesmanavatar")
                  ? "${DotEnv().env['DOMAIN']}/media/${theUser.image}"
                  : "${DotEnv().env['DOMAIN']}/media/salesmanavatar/${theUser.image}"
              : null,
          theUser.token,
        );
      } else if (response.statusCode == 404) {
        if (jsonDecode(response.body)["Error message"] == "Wrong token . User not found.") {
          vm.logoutDispatch();
          widget.showSnackBar("ورود نا معتبر. دوباره وارد شوید");
        }
      } else {
        widget.showSnackBar("خطا در ارتباط با سرور");
        throw Exception(response.statusCode);
      }
    }
  }

  void getSellersRequest({int theStateID = -1, int theCityID = -1}) async {
    setState(() => isLoading = true);
    theStateID = theStateID != -1 ? theStateID : stateId;
    theCityID = theCityID != -1 ? theCityID : cityId;
    if (states.isNotEmpty && theStateID != null) {
      final http.Response response = await http.post(
        "${DotEnv().env['DOMAIN']}/salesman/citysalesman/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'state_id': theStateID.toString(),
          'city_id': theCityID != null ? theCityID.toString() : "",
        }),
      );
      if (mounted) {
        if (response.statusCode == 200) {
          _SalesMenRequest parsedResponseSellers = _SalesMenRequest.fromJson(json.decode(response.body));
          widget.stateID.id = theStateID;
          widget.cityID.id = parsedResponseSellers.cityID;
          setState(() {
            cities = parsedResponseSellers.cities;
            cityDropdownIndex =
                parsedResponseSellers.cities.indexOf(parsedResponseSellers.cities.where((city) => city.id == parsedResponseSellers.cityID).first);
            cityId = parsedResponseSellers.cityID;
            isLoading = false;
          });
        } else if (response.statusCode == 422) {
          widget.showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
          setState(() => isLoading = false);
        } else if (response.statusCode == 404) {
          widget.showSnackBar("خطا در ارسال");
          setState(() => isLoading = false);
        } else {
          widget.showSnackBar("خطا در ارتباط با سرور");
          setState(() => isLoading = false);
          throw Exception(response.statusCode);
        }
      }
      return Future.value();
    } else {
      await getStates(theStateID: theStateID)
          ? getSellersRequest(theStateID: stateId, theCityID: theCityID)
          : throw Exception("network err : get sellers");
    }
    return Future.value();
  }

  Future<bool> getStates({int theStateID = -1}) async {
    theStateID = theStateID != -1 ? theStateID : stateId;

    final http.Response response = await http.post(
      "${DotEnv().env['DOMAIN']}/salesman/statesalesman/",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'state_id': theStateID != null ? theStateID.toString() : "",
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
        widget.showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
        return false;
      } else if (response.statusCode == 404) {
        widget.showSnackBar("خطا در ارسال");
        return false;
      } else {
        widget.showSnackBar("خطا در ارتباط با سرور");
        throw Exception(response.statusCode);
      }
    }
    return false;
  }
}

class _CheckTokenRequest {
  final bool status;
  final List<_SalesMan> salesMan;

  _CheckTokenRequest({@required this.status, this.salesMan});

  factory _CheckTokenRequest.fromJson(Map<String, dynamic> json) {
    return _CheckTokenRequest(
      status: json['Status'],
      salesMan: (json['Salesman'] as List).map((result) => _SalesMan.fromJson(result)).toList(),
    );
  }
}

class _SalesMan {
  final String userEmail;
  final String userName;
  final String phone;
  final int cityID;
  final int stateID;
  final String token;
  final bool confirmed;
  final String registerDate;
  final String address;
  final String lat;
  final String lng;
  final String image;

  _SalesMan(
      {this.phone,
      this.cityID,
      this.stateID,
      this.token,
      this.confirmed,
      this.registerDate,
      this.address,
      this.lat,
      this.lng,
      this.image,
      this.userEmail,
      this.userName});

  factory _SalesMan.fromJson(Map<String, dynamic> json) {
    return _SalesMan(
      userEmail: json['UserEmail'],
      userName: json['Username'],
      phone: json['Phone'],
      stateID: json['state'],
      cityID: json['city'],
      token: json['Token'],
      confirmed: json['Confirmed'],
      registerDate: json['RegisterDate'],
      address: json['Address'],
      lat: json['Latitude'],
      lng: json['Longitude'],
      image: json['image'],
    );
  }
}

class _SalesMenRequest {
  final bool status;
  final int cityID;
  final String cityName;
  final List<_SingleCity> cities;

  _SalesMenRequest({@required this.status, this.cityID, this.cityName, this.cities});

  factory _SalesMenRequest.fromJson(Map<String, dynamic> json) {
    return _SalesMenRequest(
      status: json['status'],
      cityID: json['city_id'],
      cityName: json['city_name'],
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
