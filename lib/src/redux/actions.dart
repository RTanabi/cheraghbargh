import 'dart:async';
import 'package:cheraghbargh/src/models/merchants_model.dart';
import 'package:latlong/latlong.dart';

import 'package:cheraghbargh/src/models/app_tab.dart';
import 'package:cheraghbargh/src/models/user_model.dart';

class RefreshCompletableAction {
  final Completer completer;

  RefreshCompletableAction({Completer completer}) : this.completer = completer ?? new Completer();
}

class UpdateTabAction {
  final AppTab newTab;
  final context;

  UpdateTabAction(this.newTab, this.context);
}

class UserLoginAction {
  final User user;

  UserLoginAction(this.user);
}

class UserTokenLoginAction {
  final String userToken;

  UserTokenLoginAction(this.userToken);
}

class UserLocationLoginAction {
  final LatLng userLocation;

  UserLocationLoginAction(this.userLocation);
}

class UserAlterProfileAction {
  final String userName;
  final String address;
  final String phone;
  final int stateID;
  final int cityID;
  final String image;
  final LatLng userLocation;
  final String token;

  UserAlterProfileAction(this.userName, this.userLocation, this.address, this.phone, this.stateID, this.cityID, this.image, this.token);
}

class UserAlterProfilePictureAction {
  final String avatarUrl;

  UserAlterProfilePictureAction(this.avatarUrl);
}

class UserTokenLogOutAction {}

class UserLogOutAction {}

class IncrementCounterAction {}

class MerchantsAction {
  final List<SingleMerchantModel> merchants;

  MerchantsAction(this.merchants);
}

class HomeSliderAction {
  final List<String> imageUrls;

  HomeSliderAction(this.imageUrls);
}

class AboutUsAction {
  final String aboutUs;

  AboutUsAction(this.aboutUs);
}
