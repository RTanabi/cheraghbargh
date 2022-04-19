// import 'package:flutter/material.dart';
import 'package:cheraghbargh/src/models/app_tab.dart';
import 'package:cheraghbargh/src/redux/actions.dart';
// import 'package:page_transition/page_transition.dart';
import 'package:redux/redux.dart';

final tabsReducer = combineReducers<AppTab>([
  TypedReducer<AppTab, UpdateTabAction>(_activeTabReducer),
]);

AppTab _activeTabReducer(AppTab activeTab, UpdateTabAction action) {
  // Navigator.push(
  //   action.context,
  //   MaterialPageRoute(
  //     builder: (context) => AppTabHelper.getValue(action.newTab)['component'],
  //   ),
  // );
  // Navigator.push(action.context, PageTransition(type: PageTransitionType.fade, child: AppTabHelper.getValue(action.newTab)['component']));
  return action.newTab;
}
