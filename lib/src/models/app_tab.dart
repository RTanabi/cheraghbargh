import 'package:cheraghbargh/src/screens/about_us.dart';
import 'package:flutter/material.dart';
import 'package:cheraghbargh/src/screens/home.dart';
import 'package:cheraghbargh/src/screens/merchants.dart';
import 'package:cheraghbargh/src/screens/profile.dart';
import 'package:cheraghbargh/src/screens/sellers.dart';

enum AppTab { aboutUs, sellers, home, merchants, profile }

class AppTabHelper {
  static Map getValue(AppTab appTab) {
    switch (appTab) {
      case AppTab.aboutUs:
        return {'icon': Icons.phone, 'title': 'درباره ما', 'key': Key('__about_us__'), 'component': AboutUs()};
      case AppTab.home:
        return {'icon': Icons.home, 'title': 'خانه', 'key': Key('__home__'), 'component': Home()};
      case AppTab.sellers:
        return {'icon': Icons.store, 'title': 'فروشندگان', 'key': Key('__sellers__'), 'component': Sellers()};
      case AppTab.merchants:
        return {'icon': Icons.chrome_reader_mode, 'title': 'بازرگانان', 'key': Key('__merchants__'), 'component': Merchants()};
      case AppTab.profile:
        return {'icon': Icons.person, 'title': 'پروفایل', 'key': Key('__profile__'), 'component': Profile()};
      default:
        return null;
    }
  }
}
