import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:k8s_api/api.dart' as k8s;
import 'package:k8s_client/util/kube_config.dart';
import 'package:openapi_dart_common/openapi.dart';
import 'package:dio/dio.dart';


// Get the access token. On GKE this must be renewed every 5 min


// the k8s api.
var server = 'https://104.196.170.22';

void main() async {
  var _dio = Dio();
  (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
      (HttpClient client) {
      // for client certificate authN, use something like this:
      //    var sc = SecurityContext();
      //    sc.setTrustedCertificates(file);
      //    var http = HttpClient(context: sc);
    // we need to ignore SSL cert errors since the host is self signed
    // todo: If we get the host cert, can we use it validate the SSL connection?
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;

    return client;
  };
  _dio.interceptors.add((LogInterceptor(responseBody: true)));

  var kubeConfig = KubeConfig();


  var token = await kubeConfig.getAccessToken();

  var oauth = OAuth(accessToken: token);

  var _api = ApiClient(
      basePath: server,
      apiClientDelegate: DioClientDelegate(_dio));
  _api.setAuthentication('BearerToken', oauth);

  var appsv1 = k8s.AppsV1Api(_api);
  var coreAPI = k8s.CoreV1Api(_api);

  // get a list of Deployments in the nightly namespace
  var r = await appsv1.listAppsV1NamespacedDeployment('nightly');

  print('got Meta data = ${r.metadata}');
  r.items.forEach((deployment) {
    print('Deployment = $deployment');
  });

  var services = await coreAPI.listCoreV1NamespacedService('nightly');

  print("services = ${services.items}");
  await _dio.close();
}
