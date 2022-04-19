import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cheraghbargh/app.dart';
import 'package:cheraghbargh/src/redux/reducers/app_state_reducer.dart';
import 'package:redux/redux.dart';
import 'package:sentry/sentry.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';
import 'package:cheraghbargh/src/redux/store.dart';

final SentryClient _sentry = new SentryClient(dsn: "https://ef3ddb294d4847f8a3fe4016b163d8e4@o345133.ingest.sentry.io/5220489");

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

Future<Null> _reportError(dynamic error, dynamic stackTrace) async {
  print('Caught error: $error');
  if (isInDebugMode) {
    print(stackTrace);
    print('In dev mode. Not sending report to Sentry.io.');
    return;
  }

  print('Reporting to Sentry.io...');

  final SentryResponse response = await _sentry.captureException(
    exception: error,
    stackTrace: stackTrace,
  );

  if (response.isSuccessful) {
    print('Success! Event ID: ${response.eventId}');
  } else {
    print('Failed to report to Sentry.io: ${response.error}');
  }
}

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (isInDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      Zone.current.handleUncaughtError(details.exception, details.stack);
    }
  };
  await DotEnv().load('.env');
  final persistor = Persistor<AppState>(
    storage: FlutterStorage(location: FlutterSaveLocation.sharedPreferences),
    serializer: JsonSerializer<AppState>(AppState.fromJson),
  );

  var initialState;
  try {
    initialState = await persistor.load();
  } catch (e) {
    initialState = AppState.initial();
  }

  final store = Store<AppState>(appReducer, initialState: initialState ?? AppState, middleware: [
    persistor.createMiddleware(),
  ]);

  runZonedGuarded(() async {
    runApp(new FlutterApp(
      store: store,
    ));
  }, (error, stackTrace) async {
    await _reportError(error, stackTrace);
  });
}
