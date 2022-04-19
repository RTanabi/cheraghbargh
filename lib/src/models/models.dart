import 'package:cheraghbargh/src/redux/store.dart';

class HomeScreenViewModel {
  final AppState state;
  final dynamic store;

  HomeScreenViewModel({this.state, this.store});
}

class GithubSearchScreenViewModel {
  final AppState state;
  final void Function(String term) onTextChanged;

  GithubSearchScreenViewModel({this.state, this.onTextChanged});
}
