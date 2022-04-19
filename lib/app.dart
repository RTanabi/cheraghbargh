import 'package:cheraghbargh/src/screens/routes/home/single_product.dart';
import 'package:cheraghbargh/src/screens/routes/merchants/merchant_location.dart';
import 'package:flutter/services.dart';
import 'package:redux/redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cheraghbargh/src/redux/store.dart';
import 'package:cheraghbargh/src/models/app_tab.dart';

class FlutterApp extends StatelessWidget {
  final Store<AppState> store;

  FlutterApp({Key key, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new StoreProvider<AppState>(
      store: store,
      child: new StoreConnector<AppState, _ViewModel>(
        converter: _ViewModel.fromStore,
        builder: (BuildContext context, _ViewModel vm) {
          return MaterialApp(
            title: 'Flutter App',
            theme: FlutterTheme.theme,
            locale: Locale("fa", "IR"),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child,
              );
            },
            routes: {
              '/singleProduct': (context) => SingleProduct(),
              '/merchantLocation': (context) => MerchantLocation(),
            },
            home: TheHome(vm: vm),
          );
        },
      ),
    );
  }
}

class TheHome extends StatefulWidget {
  final _ViewModel vm;
  const TheHome({Key key, this.vm}) : super(key: key);

  @override
  _TheHomeState createState() => _TheHomeState();
}

class _TheHomeState extends State<TheHome> {
  Widget _myAnimatedWidget;
  bool isToRight = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _myAnimatedWidget = AppTabHelper.getValue(widget.vm.activeTab)['component'];
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(0xff800020),
        statusBarIconBrightness: Brightness.light,
      ));
    });
  }

  @override
  void didUpdateWidget(TheHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm.activeTab != widget.vm.activeTab) {
      // if (widget.vm.activeTab == AppTab.home) {
      //   Future.delayed(Duration(milliseconds: 150), () {
      //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //       statusBarColor: Colors.black87, // status bar color
      //       statusBarIconBrightness: Brightness.light,
      //       systemNavigationBarColor: Colors.black, // navigation bar color
      //       systemNavigationBarIconBrightness: Brightness.light,
      //     ));
      //   });
      // } else if (widget.vm.activeTab == AppTab.profile) {
      //   Future.delayed(Duration(milliseconds: 150), () {
      //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //       statusBarColor: Theme.of(context).primaryColor, // status bar color
      //       statusBarIconBrightness: Brightness.light,
      //       systemNavigationBarColor: Colors.black87, // navigation bar color
      //       systemNavigationBarIconBrightness: Brightness.light,
      //     ));
      //   });
      // } else {
      //   Future.delayed(Duration(milliseconds: 150), () {
      //     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      //       statusBarColor: Color(0xDDFFFFFF), // status bar color
      //       statusBarIconBrightness: Brightness.dark,
      //       systemNavigationBarColor: Colors.black87, // navigation bar color
      //       systemNavigationBarIconBrightness: Brightness.light,
      //     ));
      //   });
      // }
      setState(() {
        _myAnimatedWidget = AppTabHelper.getValue(widget.vm.activeTab)['component'];
        isToRight = oldWidget.vm.activeTab.index > widget.vm.activeTab.index ? true : false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      // layoutBuilder: AnimatedSwitcher.defaultTransitionBuilder(child, animation){},
      // transitionBuilder: (Widget child, Animation animation) {
      //   // return ScaleTransition(child: child, scale: animation);
      //   // return RotationTransition(child: child, turns: Tween<double>(begin: 1, end: 7).animate(animation));
      //   // return AlignTransition(
      //   //   alignment: Tween(begin: Alignment.bottomCenter, end: Alignment.topCenter).animate(animation),
      //   //   child: child,
      //   // );
      //   return SlideTransition(
      //     position: Tween(begin: Offset(isToRight ? 1 : -1, 0), end: Offset(0, 0)).animate(animation),
      //     child: child,
      //   );
      // },
      child: SafeArea(
        key: ValueKey(widget.vm.activeTab),
        child: _myAnimatedWidget,
      ),
    );
  }
}

class _ViewModel {
  final AppTab activeTab;

  _ViewModel({
    @required this.activeTab,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      activeTab: store.state.activeTab,
    );
  }
}

class FlutterTheme {
  static ThemeData get theme {
    final themeData = ThemeData(fontFamily: 'shabnam');
    final textTheme = themeData.textTheme;
    final body1 = textTheme.bodyText2.copyWith(decorationColor: Colors.transparent);

    return ThemeData.light().copyWith(
      primaryColor: Color(0xff800020),
      accentColor: Color(0xff800020),
      buttonColor: Colors.grey[800],
      textSelectionColor: Colors.cyan[100],
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(width: 1, color: Colors.black54)),
      ),
      toggleableActiveColor: Color(0xff800020),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(0xff800020),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Color(0xff800020),
        contentTextStyle: TextStyle(fontFamily: "shabnam", color: Colors.white),
        actionTextColor: Colors.white,
      ),
      textTheme: textTheme.copyWith(
        bodyText2: body1,
      ),
    );
  }
}
