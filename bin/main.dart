import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:k8s_api/api.dart' as k8s;
import 'package:openapi_dart_common/openapi.dart';
import 'package:dio/dio.dart';


// Get the access token. On GKE this must be renewed every 5 min

var token = 'Get the access_token from your ~/.kubeconfig';

// the k8s api.
var server = 'https://xx.xx.xx.xx';

void main() async {
  var _client = k8s.LocalApiClient();
  var _dio = Dio();
  (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {

    var file = 'k8s.cert';
    var sc = SecurityContext();
    // looks like this is not required. Just the bearer token...
    //sc.setTrustedCertificates(file);
    var http = HttpClient(context: sc);
    // meed to ignore SSL cert errors since the host is self signed
    http.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return http;
  };
  _dio.interceptors.add((LogInterceptor(responseBody: true)));

  var st = token.replaceAll(RegExp(r"\s\b|\b\s"), "");
  var oauth = OAuth(accessToken: st);

  var _api = ApiClient(
      basePath: server,
      apiClientDelegate: DioClientDelegate(_dio));
  _api.setAuthentication('BearerToken', oauth);

  var appsv1 = k8s.AppsV1Api(_api);
  var coreAPI = k8s.CoreV1Api(_api);

  var r = await appsv1.listAppsV1NamespacedDeployment('nightly');

  print('got Meta data = ${r.metadata}');
  r.items.forEach((deployment) {
    print('Deployment = $deployment');
  });

  var services = await coreAPI.listCoreV1NamespacedService('nightly');

  print("services = ${services.items}");
  await _dio.close();
}
