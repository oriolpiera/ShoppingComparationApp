import 'dart:async';
import 'dart:js_interop';

@JS('fetch')
external JSPromise<_FetchResponse> _fetch(JSString resource);

extension type _FetchResponse._(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSString> text();
}

Future<String?> openFoodFactsGetRequest(Uri uri) async {
  const requestTimeout = Duration(seconds: 4);

  final response = await _fetch(uri.toString().toJS).toDart.timeout(
    requestTimeout,
  );
  if (response.status < 200 || response.status >= 300) {
    return null;
  }

  final body = await response.text().toDart.timeout(requestTimeout);
  return body.toDart;
}
