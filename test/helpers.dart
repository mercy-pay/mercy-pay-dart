import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mercy_pay/mercy_pay.dart';

/// A client whose HTTP answers come from a queue, remembering every request.
(MercyPay, List<http.Request>) fakeClient([List<Object> answers = const []]) {
  final queue = List<Object>.of(answers);
  final requests = <http.Request>[];
  final mock = MockClient((request) async {
    requests.add(request);
    final answer = queue.isEmpty ? json(200, {'data': {}}) : queue.removeAt(0);
    if (answer is Exception) throw answer;
    return answer as http.Response;
  });
  return (MercyPay('mp_sandbox_test', baseUrl: 'https://api.test', httpClient: mock, sleep: (_) async {}), requests);
}

http.Response json(int status, Object body, {Map<String, String> headers = const {}}) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json; charset=utf-8', ...headers});
