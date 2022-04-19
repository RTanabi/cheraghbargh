import 'package:cheraghbargh/src/screens/routes/home/single_product.dart' show SingleProduct;
import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;
import 'package:http/http.dart' as http;
import 'dart:convert' show json, jsonEncode;
import 'package:cached_network_image/cached_network_image.dart' show CachedNetworkImage;
import 'package:cheraghbargh/src/screens/home.dart' show ViewModel;
import 'package:flutter/material.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart' show TabSelector;

class SearchProducts extends StatefulWidget {
  final vm;
  SearchProducts({Key key, this.vm}) : super(key: key);

  @override
  _SearchProductsState createState() => _SearchProductsState(vm: vm);
}

class _SearchProductsState extends State<SearchProducts> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final ViewModel vm;
  _SearchProductsState({this.vm});
  bool isLoading = false;
  final _searchInputController = TextEditingController();
  List<_SearchResult> allSingleProduct = [];

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                Container(
                  padding: EdgeInsets.all(10),
                  child: Material(
                    elevation: 15,
                    shadowColor: Colors.black45,
                    borderRadius: BorderRadius.circular(35),
                    child: TextFormField(
                      autofocus: true,
                      style: TextStyle(fontSize: 16),
                      controller: _searchInputController,
                      onChanged: (text) => handleOnChangeSearchInput(vm, text),
                      decoration: InputDecoration(
                        hintText: 'جستجو',
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0, color: Colors.white)),
                        prefixIcon: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                _searchInputController.text.isNotEmpty
                    ? allSingleProduct
                        .map((sp) => BuildProduct(
                              vm: vm,
                              id: sp.id,
                              text: sp.name,
                              image: sp.image,
                              thumbnail: sp.thumbnail,
                            ))
                        .toList()
                    : [Center(child: Text("متنی برای جستجو وارد کنید"))],
              ),
            ),
            SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
          ],
        ),
        floatingActionButton: TabSelector(),
      ),
    );
  }

  void handleOnChangeSearchInput(ViewModel vm, String text) async {
    setState(() => isLoading = true);
    if (_searchInputController.text.isNotEmpty) {
      final http.Response response = await http.post(
        "${DotEnv().env['DOMAIN']}/salesman/search/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'token': vm.user.token.isNotEmpty ? vm.user.token : '',
        },
        body: jsonEncode(<String, String>{
          'searchChar': text,
        }),
      );

      if (response.statusCode == 200) {
        _SearchRequest parsedResponse = _SearchRequest.fromJson(json.decode(response.body));
        setState(() {
          isLoading = false;
          allSingleProduct = parsedResponse.searchresults;
        });
      } else if (response.statusCode == 422) {
        setState(() => isLoading = false);
        showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
      } else if (response.statusCode == 404) {
        setState(() {
          isLoading = false;
          allSingleProduct = [];
        });
        // showSnackBar("خطا در ارسال");
      } else {
        setState(() => isLoading = false);
        showSnackBar("خطا در ارتباط با سرور");
        throw Exception(response.statusCode);
      }
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

class BuildProduct extends StatelessWidget {
  final ViewModel vm;
  final int id;
  final String text;
  final String image;
  final String thumbnail;
  const BuildProduct({Key key, this.vm, this.id, this.text, this.image, this.thumbnail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SingleProduct(
                    vm: vm,
                    id: id,
                    image: image,
                    name: text,
                  ))),
      child: Container(
        height: 120,
        margin: EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black12,
              width: 1.7,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: thumbnail.isNotEmpty ? "${DotEnv().env['DOMAIN']}/media/$thumbnail" : "https://via.placeholder.com/150",
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(child: CircularProgressIndicator(value: downloadProgress.progress)),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RichText(
                  text: TextSpan(
                    text: text,
                    style: TextStyle(color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(text: '  ' + '', style: TextStyle(color: Theme.of(context).primaryColor)), // n mahsool
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchRequest {
  final bool status;
  final List<_SearchResult> searchresults;

  _SearchRequest({@required this.status, this.searchresults});

  factory _SearchRequest.fromJson(Map<String, dynamic> json) {
    return _SearchRequest(
      status: json['Status'],
      searchresults: (json['searchresult'] as List).map((searchResult) => _SearchResult.fromJson(searchResult)).toList(),
    );
  }
}

class _SearchResult {
  final int id;
  final String name;
  final String image;
  final String thumbnail;
  final int carpartNumber;

  _SearchResult({this.id, this.name, this.image, this.thumbnail, this.carpartNumber});

  factory _SearchResult.fromJson(Map<String, dynamic> json) {
    return _SearchResult(
      id: json['id'],
      name: json['Name'],
      image: json['image'],
      thumbnail: json['thumbnail'],
      carpartNumber: json['CarpatsNumber'],
    );
  }
}
