import 'package:redux/redux.dart';
import 'package:latlong/latlong.dart' show LatLng;
import 'package:cheraghbargh/src/models/user_model.dart';
import 'package:cheraghbargh/src/redux/actions.dart';

final userReducer = combineReducers<User>([
  TypedReducer<User, UserLoginAction>(_userLoginReducer),
  TypedReducer<User, UserLocationLoginAction>(_userChangeLocation),
  TypedReducer<User, UserAlterProfileAction>(_userAlterProfile),
  TypedReducer<User, UserAlterProfilePictureAction>(_userAlterAvatar),
  TypedReducer<User, UserLogOutAction>(_userLogoutReducer),
]);

User _userLoginReducer(User user, UserLoginAction action) {
  return user.copyWith(token: action.user.token);
}

User _userChangeLocation(User user, UserLocationLoginAction action) {
  return user.copyWith(location: action.userLocation);
}

User _userAlterProfile(User user, UserAlterProfileAction action) {
  return user.copyWith(
    name: action.userName,
    address: action.address,
    phone: action.phone,
    stateID: action.stateID,
    cityID: action.cityID,
    avatarUrl: action.image,
    location: action.userLocation,
    token: action.token,
  );
}

User _userAlterAvatar(User user, UserAlterProfilePictureAction action) {
  return user.copyWith(avatarUrl: action.avatarUrl);
}

User _userLogoutReducer(User user, UserLogOutAction action) {
  return user.copyWith(token: "", address: "", avatarUrl: "", location: new LatLng(0, 0), name: "", phone: "");
}
