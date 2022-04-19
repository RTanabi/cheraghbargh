import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:redux/redux.dart';

final aboutUsReducer = combineReducers<String>([
  TypedReducer<String, AboutUsAction>(_setAboutUs),
]);

String _setAboutUs(String aboutUs, AboutUsAction action) {
  return aboutUs = action.aboutUs;
}
