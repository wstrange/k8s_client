import 'package:k8s_client/util/kube_config.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';


main() {

  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  test('Can read default config', () async {
    var config = KubeConfig();
    expect(config.currentContextName, isNotNull);
    expect(config.contexts,isNotEmpty);
    expect(config.currentContext, isNotNull);
    expect(config.currentNamespace, isNotNull);
    expect(config.currentCluster, isNotNull);

    var token = await config.getAccessToken();
    expect(token,isNotNull);
  });


}