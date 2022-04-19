import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;
import 'package:http/http.dart' as http;
import 'dart:convert' show json;
import 'package:cheraghbargh/src/models/app_tab.dart';
import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:cheraghbargh/src/screens/routes/home/seachProducts.dart' show SearchProducts;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart' show TabSelector;
import 'package:cheraghbargh/src/models/user_model.dart' show User;
import 'package:cheraghbargh/src/redux/store.dart' show AppState;

class Home extends StatelessWidget {
  const Home({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, ViewModel>(
      distinct: true,
      converter: ViewModel.fromStore,
      builder: (context, vm) {
        return HomeChild(vm: vm);
      },
    );
  }
}

class HomeChild extends StatefulWidget {
  final ViewModel vm;
  HomeChild({Key key, @required this.vm}) : super(key: key);

  @override
  _HomeChildState createState() => _HomeChildState();
}

class _HomeChildState extends State<HomeChild> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Map> chips = [
    {'label': 'بلبرینگ'},
    {'label': 'تسمه تایم'},
    {'label': 'باطری'},
    {'label': 'دسته موتور'},
    {'label': 'روغن موتور'}
  ];

  List<_SingleImageSlider> imageSlider = [];

  @override
  void initState() {
    super.initState();
    getImageSlider(vm: widget.vm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: <Widget>[
                  if (widget.vm.sliderImgUrls == null || widget.vm.sliderImgUrls.isEmpty) SizedBox(height: 240.0),
                  if (widget.vm.sliderImgUrls != null && widget.vm.sliderImgUrls.isNotEmpty)
                    Container(
                      height: 240.0,
                      child: CarouselWithIndicatorDemo(
                        vm: widget.vm,
                      ),
                      // child: ListView(
                      //   scrollDirection: Axis.horizontal,
                      //   reverse: true,
                      //   children: widget.vm.sliderImgUrls.map((imgUrl) => ImageSlider(imageUrl: imgUrl)).toList(),
                      // ),
                    ),
                  // if (widget.vm.sliderImgUrls != null && widget.vm.sliderImgUrls.isNotEmpty)
                  //   Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: widget.vm.sliderImgUrls.map((url) {
                  //       return Container(
                  //         width: 8.0,
                  //         height: 8.0,
                  //         margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: Color.fromRGBO(0, 0, 0, 0.4),
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                ],
              )
            ]),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: MediaQuery.of(context).size.width,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    child: Column(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 45),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "استعلام قیمت قطعات خودرو",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.headline5,
                              ),
                              Text(
                                "قطعه مورد نظر خود را جستجو کنید",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            child: Material(
                              elevation: 5,
                              shadowColor: Colors.black45,
                              borderRadius: BorderRadius.circular(35),
                              child: TextFormField(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SearchProducts(vm: widget.vm)));
                                },
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: 'جستجو',
                                  border: InputBorder.none,
                                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 0, color: Colors.white)),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: 1,
            ),
          ),
          SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
        ],
      ),
      floatingActionButton: TabSelector(),
    );
  }

  Widget mapChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((item) {
          // int index = chips.indexOf(item);
          return Container(
            margin: EdgeInsets.only(left: 8.0),
            child: Chip(
              deleteIcon: Icon(
                Icons.close,
                size: 15,
                color: Colors.white,
              ),
              backgroundColor: Theme.of(context).primaryColor,
              label: Text(item['label'], style: TextStyle(color: Colors.white)),
              deleteButtonTooltipMessage: 'erase',
              onDeleted: () => handleRemoveChip(item),
            ),
          );
        }).toList(),
      ),
    );
  }

  void handleRemoveChip(Map item) {
    setState(() {
      chips.remove(item);
    });
  }

  void getImageSlider({@required ViewModel vm}) async {
    final http.Response response = await http.get(
      "${DotEnv().env['DOMAIN']}/slider/sliderimage/",
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (mounted) {
      if (response.statusCode == 200) {
        _ImageSliderRequest parsedResponse = _ImageSliderRequest.fromJson(json.decode(response.body));
        vm.dispatchHomeImageSlider(parsedResponse.imageSliders.map((e) => e.imageUrl).toList());
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

class CarouselWithIndicatorDemo extends StatefulWidget {
  final ViewModel vm;
  const CarouselWithIndicatorDemo({Key key, this.vm}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      CarouselSlider(
        items: widget.vm.sliderImgUrls
            .map(
              (item) => Container(
                child: Stack(
                  children: <Widget>[
                    Center(child: Image.network(item, fit: BoxFit.fill, width: 1000.0, height: 200)),
                  ],
                ),
              ),
            )
            .toList(),
        options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            reverse: true,
            aspectRatio: 2,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(seconds: 2),
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: widget.vm.sliderImgUrls.map((url) {
          int index = widget.vm.sliderImgUrls.indexOf(url);
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index ? Color.fromRGBO(0, 0, 0, 0.9) : Color.fromRGBO(0, 0, 0, 0.4),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

class ViewModel {
  final User user;
  final List<String> sliderImgUrls;
  final Function(int, dynamic) onTabSelected;
  final Function(List<String>) dispatchHomeImageSlider;
  ViewModel({
    this.sliderImgUrls,
    this.dispatchHomeImageSlider,
    @required this.user,
    this.onTabSelected,
  });

  static ViewModel fromStore(Store<AppState> store) {
    return ViewModel(
      user: store.state.user,
      sliderImgUrls: store.state.homeImageSlider,
      onTabSelected: (index, context) {
        store.dispatch(UpdateTabAction(AppTab.values[index], context));
      },
      dispatchHomeImageSlider: (List<String> imgUrls) {
        store.dispatch(HomeSliderAction(imgUrls));
      },
    );
  }
}

class _ImageSliderRequest {
  final bool status;
  final List<_SingleImageSlider> imageSliders;

  _ImageSliderRequest({@required this.status, this.imageSliders});

  factory _ImageSliderRequest.fromJson(Map<String, dynamic> json) {
    return _ImageSliderRequest(
      status: json['status'],
      imageSliders: (json['Slider Pictures'] as List).map((singleImageSlider) => _SingleImageSlider.fromJson(singleImageSlider)).toList(),
    );
  }
}

class _SingleImageSlider {
  final String imageUrl;

  _SingleImageSlider({this.imageUrl});

  factory _SingleImageSlider.fromJson(Map<String, dynamic> json) {
    return _SingleImageSlider(
      imageUrl: json['image_url'],
    );
  }
}
