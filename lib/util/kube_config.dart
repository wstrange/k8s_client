import 'dart:io';
import 'package:k8s_client/util/authenticator.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

class KubeConfig {
  final log = Logger('KubeConfig');
  static final String ENV_HOME = "HOME";
  static final String KUBEDIR = ".kube";
  static final String KUBECONFIG = "config";

  Map<String, Authenticator> authenticators = {};
  List clusters;
  List contexts;
  List users;
  String currentContextName;
  Map<String, Object> currentContext;
  Map<String, Object> currentCluster;
  Map<String, Object> currentUser;
  String currentNamespace;

  _init() {
    var gcp = GCPAuthenticator();
    authenticators[gcp.name] = gcp;
  }

  KubeConfig() {
    _init();
    var home = Platform.environment[ENV_HOME];
    var kubeFile = File('$home/$KUBEDIR/$KUBECONFIG');
    var c = kubeFile.readAsStringSync();
    _initFromString(c);
  }

  void _initFromString(String c) {
    //log.finest("READ Config File: \n$c");
    var yaml = loadYaml(c);
    log.finest('Yaml = $yaml');
    this.currentContextName = yaml['current-context'];
    log.finest('current context = $currentContextName');
    contexts = yaml['contexts'] as List;
    clusters = yaml['clusters'] as List;
    users = yaml['users'] as List;

    this.setContext(currentContextName);
    // preferences?
  }

  bool setContext(String name) {
    if (name == null) {
      return false;
    }
    currentContextName = name;
    var yamlMap = contexts.firstWhere((e) => e['name'] == name) as YamlMap;
    currentContext = yamlMap['context'].cast<String, Object>();
    log.finest('current context = $currentContext');
    var u = currentContext['user'] as String;
    var uMap = users.firstWhere((e) => e['name'] == u);
    currentUser = uMap['user'].cast<String, Object>();
    log.finest("Current user map = $currentUser");
    currentNamespace = currentContext['namespace'] as String;
    var cluster = currentContext['cluster'] as String;
    var cMap = clusters.firstWhere((e) => e['name'] == cluster);
    currentCluster = cMap['cluster'].cast<String, Object>();
    return true;
  }

  String get currentServer => currentCluster['server'];

  Future<String> getAccessToken() async {
    if (currentUser == null) {
      return null;
    }
    var authProvider = currentUser['auth-provider'] as Map;
    log.fine("authProvider: $authProvider");
    var authConfig = authProvider['config'].cast<String,Object>();
    log.fine('authConfig = $authConfig');
    if (authProvider != null) {
      var name = authProvider['name'];
      var auth = authenticators[name];
      if (auth != null) {
        if (auth.isExpired(authConfig)) {
          authConfig = await auth.refresh(authConfig);
          // todo: impl"ement persisting config back..
              log.warning('Configuration Persister is not implemented');
        }
        return auth.getToken(authConfig);
      } else {
        log.severe('Cant find authenticator for $name');
      }
    }
    log.severe('No Auth Provider found');
    return null;
  }
}
