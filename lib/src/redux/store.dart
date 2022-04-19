import 'dart:developer' as developer;

import 'package:cheraghbargh/main.dart' show isInDebugMode;
import 'package:cheraghbargh/src/models/app_tab.dart' show AppTab;
import 'package:cheraghbargh/src/models/merchants_model.dart' show SingleMerchantModel;
import 'package:cheraghbargh/src/models/user_model.dart' show User;

class AppState {
  final AppTab activeTab;
  final String aboutUs;
  final User user;
  final List<SingleMerchantModel> merchants;
  final List<String> homeImageSlider;

  AppState({
    this.activeTab = AppTab.home,
    this.user,
    this.aboutUs,
    this.homeImageSlider,
    this.merchants,
  });

  factory AppState.initial() => new AppState(
        activeTab: AppTab.home,
        aboutUs: "",
        user: new User(token: ""),
        merchants: null,
        homeImageSlider: null,
      );

  AppState copyWith({activeTab, aboutUs, user, merchants, homeImageSlider}) {
    return AppState(
      activeTab: activeTab ?? this.activeTab,
      aboutUs: aboutUs ?? this.aboutUs,
      user: user ?? this.user,
      merchants: merchants ?? this.merchants,
      homeImageSlider: homeImageSlider ?? this.homeImageSlider,
    );
  }

  static AppState fromJson(dynamic json) {
    if (isInDebugMode) developer.log(json.toString(), name: "json", level: 1000);
    return json != null
        ? AppState(
            // aboutUs: json['aboutUs'] as String,
            user: User.fromJson(json['user']),
          )
        : AppState.initial();
  }

  dynamic toJson() => {
        // 'aboutUs': aboutUs,
        'user': user.toJson(),
      };
}
