import 'package:cheraghbargh/src/components/marquee_text.dart';
import 'package:cheraghbargh/src/screens/routes/merchants/merchant_location.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cheraghbargh/src/models/merchants_model.dart';
import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:cheraghbargh/src/redux/store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class Merchants extends StatefulWidget {
  const Merchants({Key key}) : super(key: key);

  @override
  _MerchantsState createState() => _MerchantsState();
}

class _MerchantsState extends State<Merchants> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: StoreConnector<AppState, MerchantsViewModel>(
        distinct: true,
        converter: MerchantsViewModel.fromStore,
        builder: (context, vm) {
          return Scaffold(
            key: _scaffoldKey,
            body: MerchantsChild(
              vm: vm,
            ),
            floatingActionButton: TabSelector(),
          );
        },
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
}

class MerchantsChild extends StatefulWidget {
  final MerchantsViewModel vm;
  final void Function(Text) showSnackBar;
  MerchantsChild({Key key, this.vm, this.showSnackBar}) : super(key: key);

  @override
  _MerchantsChildState createState() => _MerchantsChildState();
}

class _MerchantsChildState extends State<MerchantsChild> {
  @override
  void initState() {
    super.initState();
    fetchMerchantsRequest(widget.vm, widget.showSnackBar);
  }

  @override
  Widget build(BuildContext context) {
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
                " بازرگانان یدکی",
                style: TextStyle(color: Colors.black, fontSize: 15, fontFamily: "shabnam"),
              ),
            ),
            titlePadding: EdgeInsets.only(top: 20),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(widget.vm.merchants != null && widget.vm.merchants.length > 0 && widget.vm.merchants.first != null
              ? widget.vm.merchants.map((SingleMerchantModel merchant) => BuildSellers(merchant: merchant)).toList()
              : [Center(child: CircularProgressIndicator())]),
        ),
        SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
      ],
    );
  }

  void fetchMerchantsRequest(MerchantsViewModel vm, showSnackBar) async {
    final http.Response response = await http.get(
      "${DotEnv().env['DOMAIN']}/visitor/getlist/",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (mounted) {
      if (response.statusCode == 200) {
        MerchantRequest jsonResponse = MerchantRequest.fromJson(json.decode(response.body));
        List<SingleMerchantModel> merchantList = jsonResponse.merchants.map((merchant) {
          SingleMerchantModel singleMerchantModel = new SingleMerchantModel();
          return singleMerchantModel.copyWith(
            name: merchant.name,
            phone: merchant.phone,
            photo: merchant.photo != null && merchant.photo.isNotEmpty
                ? "${DotEnv().env['DOMAIN']}/media/${merchant.photo}"
                : "https://via.placeholder.com/300x100",
            address: merchant.address,
            latitude: merchant.latitude,
            longitude: merchant.longitude,
            pdfUrl: merchant.pdfUrl,
          );
        }).toList();
        vm.setMerchantsDispatch(merchantList);
      } else if (response.statusCode == 422) {
        showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
      } else if (response.statusCode == 404) {
        showSnackBar("خطا در ارسال");
      } else {
        showSnackBar("خطا در ارتباط با سرور");
        throw Exception(response.statusCode);
      }
    }
  }
}

class BuildSellers extends StatelessWidget {
  final SingleMerchantModel merchant;
  const BuildSellers({Key key, this.merchant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MerchantLocation(
            address: merchant.address,
            phone: merchant.phone,
            lat: double.parse(merchant.latitude),
            lng: double.parse(merchant.longitude),
            name: merchant.name,
            pdfUrl: merchant.pdfUrl,
          ),
        ),
      ),
      child: Container(
        height: 140,
        width: double.infinity,
        padding: EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Stack(
            children: <Widget>[
              Image.network(
                merchant.photo,
                width: double.infinity,
                fit: BoxFit.fill,
                colorBlendMode: BlendMode.darken,
                color: Colors.black38,
                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
              Center(
                child: MarqueeWidget(
                  animationDuration: Duration(seconds: 8),
                  backDuration: Duration(seconds: 3),
                  child: Text(
                    "${merchant.name}",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                      fontSize: 20,
                      color: Colors.white,
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 6.0,
                          color: Color.fromARGB(128, 0, 0, 0),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MerchantsViewModel {
  final List<SingleMerchantModel> merchants;
  final Function(List<SingleMerchantModel>) setMerchantsDispatch;

  MerchantsViewModel({
    @required this.merchants,
    @required this.setMerchantsDispatch,
  });

  static MerchantsViewModel fromStore(Store<AppState> store) {
    return MerchantsViewModel(
      merchants: store.state.merchants,
      setMerchantsDispatch: (List<SingleMerchantModel> merchantsList) {
        store.dispatch(MerchantsAction(merchantsList));
      },
    );
  }
}

class MerchantRequest {
  final bool status;
  final List<_SingleMerchant> merchants;

  MerchantRequest({@required this.status, this.merchants});

  factory MerchantRequest.fromJson(Map<String, dynamic> json) {
    return MerchantRequest(
      status: json['Status'],
      merchants: (json['VisitorList'] as List).map((merchant) => _SingleMerchant.fromJson(merchant)).toList(),
    );
  }
}

class _SingleMerchant {
  final String name;
  final String phone;
  final String photo;
  final String latitude;
  final String longitude;
  final String pdfUrl;
  final String address;

  _SingleMerchant({this.phone, this.photo, this.latitude, this.longitude, this.pdfUrl, this.address, this.name});

  factory _SingleMerchant.fromJson(Map<String, dynamic> json) {
    return _SingleMerchant(
      name: json["name"],
      phone: json["phone"],
      photo: json["photo"],
      latitude: json["Latitude"],
      longitude: json["Longitude"],
      pdfUrl: json["pdf_url"],
      address: json["Address"],
    );
  }
}
