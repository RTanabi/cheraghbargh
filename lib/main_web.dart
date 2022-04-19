import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cheraghbargh/app.dart';
import 'package:cheraghbargh/src/redux/reducers/app_state_reducer.dart';

import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:cheraghbargh/src/redux/store.dart';
import 'package:redux_persist_web/redux_persist_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DotEnv().load('.env');
  final persistor = Persistor<AppState>(
    storage: WebStorage(),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
    // debug: true,
  );

  // Load initial state
  final initialState = await persistor.load();

  final store = Store<AppState>(appReducer, initialState: initialState ?? AppState, middleware: [
    persistor.createMiddleware(),
  ]);

  // Do a initial call for posts
  // store.dispatch(FetchPostsAction(FetchPostsEnumType.fresh));
  //print(store);
  runApp(new FlutterApp(
    store: store,
  ));
}
