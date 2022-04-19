import 'package:cheraghbargh/src/models/merchants_model.dart';
import 'package:redux/redux.dart';
import 'package:cheraghbargh/src/redux/actions.dart';

final merchantsReducer = combineReducers<List<SingleMerchantModel>>([
  TypedReducer<List<SingleMerchantModel>, MerchantsAction>(_userLoginReducer),
]);

List<SingleMerchantModel> _userLoginReducer(List<SingleMerchantModel> merchants, MerchantsAction action) {
  return merchants = action.merchants;
}
