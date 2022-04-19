import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:cheraghbargh/src/components/auth/login_confirm.dart' show LoginConfirm;
import 'package:cheraghbargh/src/components/auth/login_phone.dart' show LoginPhone;
import 'package:cheraghbargh/src/components/auth/profile_form.dart' show ProfileForm;
import 'package:flutter_dotenv/flutter_dotenv.dart' show DotEnv;
import 'package:latlong/latlong.dart' show LatLng;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:cheraghbargh/src/components/tab_selector.dart' show TabSelector;
import 'package:cheraghbargh/src/models/user_model.dart' show User;
import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:cheraghbargh/src/redux/store.dart' show AppState;
import 'package:redux/redux.dart';

class Profile extends StatefulWidget {
  Profile({Key key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isKeyboardClose = true;
  bool isConfirmSms = false;
  bool isLoading = false;
  bool isAvatarUploading = false;
  SetterGetterInt cityID = new SetterGetterInt();
  SetterGetterInt stateID = new SetterGetterInt();
  final _loginController = TextEditingController();
  final _loginControllerMoarref = TextEditingController();
  final _confirmController = TextEditingController();
  final _profileNameController = TextEditingController();
  final _profileAddressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: handleBackButton,
      child: StoreConnector<AppState, ProfileViewModel>(
        distinct: true,
        converter: ProfileViewModel.fromStore,
        builder: (context, vm) {
          // if (vm.user.token.isEmpty) fourceLogin(vm);
          return Scaffold(
            key: _scaffoldKey,
            body: CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  pinned: false,
                  floating: false,
                  actions: <Widget>[
                    if (vm.user.token.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.exit_to_app, size: 30, color: Colors.white),
                        onPressed: vm.logoutDispatch,
                      ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(65.0),
                    child: Container(),
                  ),
                  expandedHeight: 300.0,
                  backgroundColor: Colors.white10,
                  flexibleSpace: Stack(
                    children: <Widget>[
                      FractionallySizedBox(
                        heightFactor: 0.6,
                        widthFactor: 1,
                        child: Container(
                          alignment: Alignment.topCenter,
                          padding: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                          ),
                          child: Text(
                            vm.user.token != null && vm.user.token.isNotEmpty ? "پروفایل" : "ورود/ثبت نام",
                            style: Theme.of(context).textTheme.headline5.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 60, right: 80, left: 80),
                        alignment: Alignment.center,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 5.0,
                                  spreadRadius: 2.5,
                                )
                              ],
                              image: DecorationImage(
                                image: vm.user.token.isEmpty || vm.user.avatarUrl.isEmpty
                                    ? AssetImage('assets/images/default_avatar.png')
                                    : NetworkImage(vm.user.avatarUrl),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(500),
                            ),
                            child: vm.user.token.isNotEmpty
                                ? Container(
                                    width: 67,
                                    height: 67,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(500),
                                    ),
                                    child: !isAvatarUploading
                                        ? IconButton(
                                            icon: Icon(
                                              Icons.camera,
                                              size: 45,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => getImage(vm),
                                          )
                                        : CircularProgressIndicator(backgroundColor: Colors.white70),
                                  )
                                : Container(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (vm.user.token.isNotEmpty)
                        ProfileForm(
                          vm: vm,
                          superContext: context,
                          showSnackBar: showSnackBar,
                          profileAddressController: _profileAddressController,
                          profileNameController: _profileNameController,
                          cityID: cityID,
                          stateID: stateID,
                        ),
                      if (vm.user.token.isEmpty && !isConfirmSms)
                        LoginPhone(
                          vm: vm,
                          loginController: _loginController,
                          loginControllerMoarref: _loginControllerMoarref,
                        ),
                      if (vm.user.token.isEmpty && isConfirmSms) LoginConfirm(vm: vm, confirmController: _confirmController),
                    ],
                  ),
                ),
                SliverList(
                    delegate: SliverChildListDelegate([
                  Container(
                    constraints: BoxConstraints(minWidth: 100, maxWidth: 200, maxHeight: 55, minHeight: 50),
                    margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.3, vertical: 20),
                    child: Center(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(10.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        splashColor: Colors.white24,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(
                              isConfirmSms ? "ارسال" : vm.user.token.isNotEmpty ? "اعمال" : "ادامه",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 7),
                            isLoading
                                ? SizedBox(
                                    child: CircularProgressIndicator(backgroundColor: Colors.white),
                                    height: 20.0,
                                    width: 20.0,
                                  )
                                : SizedBox(
                                    child: Icon(Icons.navigate_next, color: Colors.white),
                                    height: 20.0,
                                    width: 20.0,
                                  ),
                          ],
                        ),
                        onPressed: () => handleClick(vm),
                      ),
                    ),
                  )
                ])),
                SliverList(delegate: SliverChildListDelegate([Container(height: 70)])),
              ],
            ),
            floatingActionButton: TabSelector(),
          );
        },
      ),
    );
  }

  void handleClick(ProfileViewModel vm) async {
    if (vm.user.token.isNotEmpty && isLoading == false) {
      setState(() => isLoading = true);
      String uname = _profileNameController.text.isNotEmpty ? _profileNameController.text : vm.user.name;
      String address = _profileAddressController.text.isNotEmpty ? _profileAddressController.text : vm.user.address;
      final http.Response response = await http.post(
        "${DotEnv().env['DOMAIN']}/salesman/modifyprofile/",
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "token": vm.user.token,
          "Username": uname,
          "Address": address,
          "UserEmail": "",
          "state_id": stateID.id.toString(),
          "city_id": cityID.id.toString(),
        }),
      );
      if (mounted) {
        if (response.statusCode == 200) {
          setState(() => isLoading = false);
          vm.userAlterProfileAction(
            uname,
            vm.user.location,
            address,
            vm.user.phone,
            stateID.id,
            cityID.id,
            vm.user.avatarUrl,
            vm.user.token,
          );
          showSnackBar("تغییرات با موفقیت اعمال شد");
        } else if (response.statusCode == 422) {
          setState(() => isLoading = false);
          showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
        } else if (response.statusCode == 404) {
          setState(() => isLoading = false);
          showSnackBar("خطا در ارسال");
        } else {
          showSnackBar("خطا در ارتباط با سرور");
          setState(() => isLoading = false);
          throw Exception(response.statusCode);
        }
      }
    } else if (!isConfirmSms) {
      if (_loginController.text.isNotEmpty && _loginControllerMoarref.text.isNotEmpty && isLoading == false) {
        setState(() => isLoading = true);
        final http.Response response = await http.post(
          "${DotEnv().env['DOMAIN']}/loginapi/Salesman/",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'phone': _loginController.text.substring(1),
            'invitationCode': _loginControllerMoarref.text,
          }),
        );
        if (mounted) {
          if (response.statusCode == 200) {
            setState(() {
              isLoading = false;
              isConfirmSms = true;
            });
            showSnackBar("کد دریافتی sms را وارد کنید");
          } else if (response.statusCode == 422) {
            setState(() => isLoading = false);
            showSnackBar(" شماره تلفن یا کد معرف نامعتبر است ");
          } else if (response.statusCode == 404) {
            setState(() => isLoading = false);
            showSnackBar("خطا در ارسال");
          } else {
            showSnackBar("خطا در ارتباط با سرور");
            setState(() => isLoading = false);
            throw Exception(response.statusCode);
          }
        }

        _confirmController.clear();
      }
    } else if (isConfirmSms) {
      if (_confirmController.text.isNotEmpty && _loginController.text.isNotEmpty && isLoading == false) {
        setState(() => isLoading = true);
        final http.Response response = await http.post(
          "${DotEnv().env['DOMAIN']}/loginapi/SalesmanConfirm/",
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'digit': _confirmController.text,
            'phone': _loginController.text.substring(1),
          }),
        );
        if (mounted) {
          if (response.statusCode == 201) {
            LoginConfirmRequest jsonResponse = LoginConfirmRequest.fromJson(json.decode(response.body));
            setState(() => isLoading = false);
            vm.loginDispatch(jsonResponse.token);
            showSnackBar("ورود با موفقیت انجام شد");
          } else if (response.statusCode == 422) {
            _confirmController.clear();
            _loginController.clear();
            _loginControllerMoarref.clear();
            setState(() {
              isLoading = false;
              isConfirmSms = false;
            });
            showSnackBar(" خطا در ارسال. ورودی ها را چک کنید");
          } else if (response.statusCode == 404) {
            _confirmController.clear();
            _loginController.clear();
            _loginControllerMoarref.clear();
            setState(() {
              isLoading = false;
              isConfirmSms = false;
            });
            showSnackBar("خطا در ارسال");
          } else {
            _confirmController.clear();
            _loginController.clear();
            _loginControllerMoarref.clear();
            setState(() {
              isLoading = false;
              isConfirmSms = false;
            });
            showSnackBar("خطا در ارتباط با سرور");
            setState(() => isLoading = false);
            throw Exception(response.statusCode);
          }
        }
      }
    }
  }

  Future<bool> handleBackButton() {
    if (isConfirmSms) {
      setState(() {
        isConfirmSms = false;
      });
    }
    return Future.value(false);
  }

  void getImage(ProfileViewModel vm) async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    int maxLength = 20971520;
    int fileLength = image != null ? await image.length() : null;
    if (image != null && image.path.isNotEmpty && fileLength <= maxLength && mounted) {
      var postUri = Uri.parse("${DotEnv().env['DOMAIN']}/salesman/uploadpicture/");
      var request = new http.MultipartRequest("POST", postUri);
      request.fields['Token'] = vm.user.token;
      request.files.add(await http.MultipartFile.fromPath('image', image.path));
      if (mounted) setState(() => isAvatarUploading = true);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        if (mounted) setState(() => isAvatarUploading = false);

        final respStr = await http.Response.fromStream(response);
        vm.alterAvatarDispatch(jsonDecode(respStr.body)['Message']);
      } else {
        if (mounted) setState(() => isAvatarUploading = false);
        showSnackBar("ارسال با خطا مواجه شد" + response.statusCode.toString());
      }
    } else if (fileLength != null && fileLength > maxLength + 1) {
      showSnackBar("حداکثر حجم فایل باید زیر 2 مگابایت باشد");
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

  void fourceLogin(ProfileViewModel vm) {
    //TODO:remove later
    // vm.loginDispatch("_____");
  }
}

class ProfileViewModel {
  final User user;
  final Function(String) loginDispatch;
  final Function(String, LatLng, String, String, int, int, String, String) userAlterProfileAction;
  final Function(LatLng) changeLocationDispatch;
  final Function(String) alterAvatarDispatch;
  final Function() logoutDispatch;

  ProfileViewModel({
    @required this.user,
    @required this.loginDispatch,
    @required this.userAlterProfileAction,
    @required this.changeLocationDispatch,
    @required this.alterAvatarDispatch,
    @required this.logoutDispatch,
  });

  static ProfileViewModel fromStore(Store<AppState> store) {
    return ProfileViewModel(
      user: store.state.user,
      loginDispatch: (String token) {
        store.dispatch(UserLoginAction(new User(token: token)));
      },
      logoutDispatch: () {
        store.dispatch(UserLogOutAction());
      },
      changeLocationDispatch: (LatLng position) {
        store.dispatch(UserLocationLoginAction(position));
      },
      userAlterProfileAction:
          (String userName, LatLng userLocation, String address, String phone, int stateID, int cityID, String image, String token) {
        store.dispatch(UserAlterProfileAction(userName, userLocation, address, phone, stateID, cityID, image, token));
      },
      alterAvatarDispatch: (String avatarUrl) {
        store.dispatch(UserAlterProfilePictureAction("${DotEnv().env['DOMAIN']}$avatarUrl"));
      },
    );
  }
}

class LoginConfirmRequest {
  final bool status;
  final String message;
  final String token;

  LoginConfirmRequest({@required this.status, this.message, this.token});

  factory LoginConfirmRequest.fromJson(Map<String, dynamic> json) {
    return LoginConfirmRequest(
      status: json['Status'],
      message: json['Message'],
      token: json['Token'],
    );
  }
}

class SetterGetterInt {
  int _iD = 4;
  int get id => _iD;
  set id(int theID) {
    if (theID >= 0) {
      _iD = theID;
    }
  }
}
