import 'package:cheraghbargh/src/components/marquee_text.dart';
import 'package:cheraghbargh/src/screens/home.dart' show ViewModel;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart' show TabSelector;
import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;
import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonEncode;
import 'package:url_launcher/url_launcher.dart' show launch;

class SingleProduct extends StatefulWidget {
  final vm;
  final id;
  final image;
  final String name;
  const SingleProduct({Key key, this.vm, this.id, this.image, this.name}) : super(key: key);

  @override
  _SingleProductState createState() => _SingleProductState(vm: vm, id: id, image: image);
}

class _SingleProductState extends State<SingleProduct> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<_GetDetailRequest> futureOrderRequest;
  final ViewModel vm;
  final int id;
  final String image;
  bool isLoading = false;
  List ordersList = [];
  _SingleProductState({this.vm, this.id, this.image});
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();
    futureOrderRequest = fetchOrders(vm, id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: MarqueeWidget(
          child: Text(
            widget.name,
            style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            floating: false,
            leading: Container(),
            expandedHeight: 180.0,
            backgroundColor: Colors.white10,
            flexibleSpace: Stack(
              children: <Widget>[
                FractionallySizedBox(
                  heightFactor: 0.6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        image: DecorationImage(
                          image: NetworkImage(
                              image != null && image.isNotEmpty ? "${DotEnv().env['DOMAIN']}/media/$image" : "https://via.placeholder.com/150"),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SliverList(delegate: SliverChildListDelegate([Container(height: 30)])),
          SliverList(
            delegate: SliverChildListDelegate([
              SingleChildScrollView(
                controller: _scrollController,
                child: FutureBuilder<_GetDetailRequest>(
                  future: futureOrderRequest,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text("خطا در سرور");
                    }
                    return Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHRows(),
                                    if (snapshot.hasData)
                                      ...snapshot.data.orderList.asMap().entries.map((value) {
                                        int idx = value.key;
                                        return _buildRows(idx, snapshot.data.orderList[idx]);
                                      }),
                                    if (!snapshot.hasData)
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10),
                                        width: MediaQuery.of(context).size.width,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]),
          ),
          SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
        ],
      ),
      floatingActionButton: TabSelector(),
    );
  }

  Widget _buildHRows() {
    List<String> headerTables = [
      "برند",
      "بازرگانی",
      "پرداخت",
      "قیمت",
      "سفارش",
    ];
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: Color(0xFF55000000)),
        ),
      ),
      child: Row(
        children: headerTables
            .map(
              (value) => Container(
                alignment: Alignment.center,
                color: Colors.white10,
                width: 70.0,
                height: 30.0,
                margin: EdgeInsets.all(6.0),
                child: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRows(int i, _Order order) {
    return Container(
      color: i % 2 == 0 ? Colors.black12 : Colors.white10,
      child: Row(
        children: <Widget>[
          _buildCells(order.brand),
          _buildCells(order.commercialName != null && order.commercialName.isNotEmpty ? order.commercialName : ''),
          _buildCells(order.tradeType),
          _buildCells(order.price),
          // _buildCells(order.visitorId),
          Container(
            alignment: Alignment.center,
            width: 70.0,
            height: 30.0,
            margin: EdgeInsets.all(6.0),
            child: FlatButton(
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
              splashColor: Colors.white30,
              onPressed: () {
                launch("tel://0${order.visitorId}");
              },
              child: Text(
                "تماس",
                style: TextStyle(fontSize: 11.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCells(String text) {
    if (text != null && text.isNotEmpty) {
      return Container(
        alignment: Alignment.center,
        width: 70.0,
        height: 30.0,
        margin: EdgeInsets.all(6.0),
        child: MarqueeWidget(
          pauseDuration: Duration(seconds: 1),
          animationDuration: Duration(seconds: 5),
          child: Text(text, style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 13)),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: 70.0,
        height: 30.0,
        margin: EdgeInsets.all(6.0),
        child: FlatButton(
          color: Theme.of(context).primaryColor,
          textColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          splashColor: Colors.white30,
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            }
            vm.onTabSelected(4, context);
          },
          child: Text(
            "وارد شوید",
            style: TextStyle(fontSize: 9.0),
          ),
        ),
      );
    }
  }

  Future<_GetDetailRequest> fetchOrders(ViewModel vm, int id) async {
    // setState(() => isLoading = true);
    String url = vm.user.token.isEmpty ? "${DotEnv().env['DOMAIN']}/guestapi/GuestGetDetail/" : "${DotEnv().env['DOMAIN']}/salesman/getdetail/";
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': "$id",
        'token': vm.user.token.isNotEmpty ? vm.user.token : '',
      }),
    );

    if (response.statusCode == 200) {
      return _GetDetailRequest.fromJson(json.decode(response.body));
      // setState(() {
      //   isLoading = false;
      //   ordersList = parsedResponse.orderList;
      // });
    } else if (response.statusCode == 422) {
      // setState(() => isLoading = false);
      showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
      return new _GetDetailRequest(status: true, orderList: []);
    } else if (response.statusCode == 404) {
      // setState(() => isLoading = false);
      showSnackBar("خطا در ارسال");
      return new _GetDetailRequest(status: true, orderList: []);
    } else {
      // setState(() => isLoading = false);
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

class _GetDetailRequest {
  final bool status;
  final List<_Order> orderList;

  _GetDetailRequest({@required this.status, this.orderList});

  factory _GetDetailRequest.fromJson(Map<String, dynamic> json) {
    return _GetDetailRequest(
      status: json['Status'],
      orderList: (json['Orders list'] as List).map((order) => _Order.fromJson(order)).toList(),
    );
  }
}

class _Order {
  final int id;
  final String commercialName;
  final int carpartId;
  final String brand;
  final String registerDate;
  final String visitorId;
  final String tradeType;
  final int cityId;
  final String price;

  _Order({this.id, this.commercialName, this.carpartId, this.brand, this.registerDate, this.visitorId, this.tradeType, this.cityId, this.price});

  factory _Order.fromJson(Map<String, dynamic> json) {
    return _Order(
      id: json['id'],
      commercialName: json['commercial_name'],
      carpartId: json['carpart_id'],
      brand: json['brand'],
      registerDate: json['RegisterDate'],
      visitorId: json['visitor_id'],
      tradeType: json['TradeType'],
      cityId: json['city_id'],
      price: json['price'],
    );
  }
}
