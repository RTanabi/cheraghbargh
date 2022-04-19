import 'package:cheraghbargh/src/redux/reducers/aboutus_reducer.dart';
import 'package:cheraghbargh/src/redux/reducers/home_image_slider.dart';
import 'package:cheraghbargh/src/redux/reducers/merchants_reducer.dart';
import 'package:cheraghbargh/src/redux/store.dart';
// import 'package:cheraghbargh/src/redux/reducers/counter_reducer.dart';
import 'package:cheraghbargh/src/redux/reducers/tabs_reducer.dart';
import 'package:cheraghbargh/src/redux/reducers/user_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    // counter: counterReducer(state.counter, action),
    aboutUs: aboutUsReducer(state.aboutUs, action),
    activeTab: tabsReducer(state.activeTab, action),
    user: userReducer(state.user, action),
    homeImageSlider: homeImageSliderReducer(state.homeImageSlider, action),
    merchants: merchantsReducer(state.merchants, action),
  );
}
