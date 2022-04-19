import 'package:redux/redux.dart';
import 'package:cheraghbargh/src/redux/actions.dart';

final homeImageSliderReducer = combineReducers<List<String>>([
  TypedReducer<List<String>, HomeSliderAction>(_homeImageSliderReducer),
]);

List<String> _homeImageSliderReducer(List<String> imgUrls, HomeSliderAction action) {
  return imgUrls = action.imageUrls;
}
