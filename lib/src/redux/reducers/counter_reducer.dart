import 'package:cheraghbargh/src/redux/actions.dart';
import 'package:redux/redux.dart';

final counterReducer = combineReducers<int>([
  TypedReducer<int, IncrementCounterAction>(_counter),
]);

int _counter(int counter, IncrementCounterAction action) {
  return counter = counter + 1;
}
