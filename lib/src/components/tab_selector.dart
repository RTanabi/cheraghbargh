import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cheraghbargh/src/models/app_tab.dart';
import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:cheraghbargh/src/redux/store.dart';
import 'package:redux/redux.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class TabSelector extends StatefulWidget {
  TabSelector({Key key}) : super(key: key);

  @override
  _TabSelectorState createState() => _TabSelectorState();
}

class _TabSelectorState extends State<TabSelector> {
  bool isKeyboardClose = true;

  @protected
  void initState() {
    super.initState();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (mounted) setState(() => isKeyboardClose = !visible);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: _ViewModel.fromStore,
      builder: (context, vm) {
        if (isKeyboardClose) {
          return Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(right: 30),
              decoration: new BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(
                      0.0,
                      10.0,
                    ),
                  )
                ],
                borderRadius: new BorderRadius.circular(30),
              ),
              width: 260,
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: AppTab.values.map((tab) {
                  int index = AppTab.values.indexOf(tab);
                  return Expanded(
                    child: SizedBox.fromSize(
                      size: Size(48, 48),
                      child: ClipOval(
                        child: Material(
                          color: Colors.white.withOpacity(0),
                          child: InkWell(
                            splashColor: Colors.black12,
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.popUntil(context, ModalRoute.withName('/'));
                              }
                              vm.onTabSelected(index, context);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  AppTabHelper.getValue(tab)['icon'],
                                  size: index == 2 ? 40 : AppTab.values.indexOf(vm.activeTab) == index ? 27 : 25,
                                  key: AppTabHelper.getValue(tab)['key'],
                                  color: AppTab.values.indexOf(vm.activeTab) == index ? Theme.of(context).primaryColor : Color(0x83000000),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}

class _ViewModel {
  final AppTab activeTab;
  final context;
  final Function(int, dynamic) onTabSelected;

  _ViewModel({
    @required this.activeTab,
    this.context,
    @required this.onTabSelected,
  });

  static _ViewModel fromStore(Store<AppState> store) {
    return _ViewModel(
      activeTab: store.state.activeTab,
      onTabSelected: (index, context) {
        store.dispatch(UpdateTabAction(AppTab.values[index], context));
      },
    );
  }

  // @override
  // bool operator ==(Object other) => identical(this, other) || other is _ViewModel && runtimeType == other.runtimeType && activeTab == other.activeTab;

  // @override
  // int get hashCode => activeTab.hashCode;
}
