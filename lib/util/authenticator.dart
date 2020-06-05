
import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

final log = Logger('authenticator');

abstract class Authenticator {

  String get name;

  // Get a token from the authenticator
  String getToken(Map<String, Object> config);

  bool isExpired(Map<String, Object> config);

  /** Refresh an expired token with a new fresh one. */
  Future<Map<String, Object>> refresh(Map<String, Object> config);
}

class GCPAuthenticator implements Authenticator {
  @override
  String getToken(Map<String, Object> config) {
    log.fine('gcp: get access token from $config');
    return config['access-token'];
  }

  @override
  bool isExpired(Map<String, Object> config) {
    log.fine('gcp: isExpired $config');
    try {
      var expiryObj = config['expiry'];
      var expiry = DateTime.parse(expiryObj);
      var exp = expiry.compareTo(DateTime.now()) < 0;
      log.fine("gcp: isExpired $exp");
      return exp;
    }
    catch(e) {
      log.severe('Error parsing token expiry $e');
      rethrow;
    }
  }

  @override
  String get name => "gcp";

  /// The .kube/config has helper commands that get called to
  /// refresh a token. For GCP this is the gcloud command
  /// This method invokes the helper command, and updates the configuration
  /// with the new refreshed config.
  @override
  Future<Map<String, Object>> refresh(Map<String, Object> config) async {
    var cmd = config['cmd-path'] as String;
    var args = config['cmd-args'] as String;
    // todo: We should take the json path from the config...
    // var tokenKey = config['token-key'];

    log.fine('gcp: refresh $cmd $args');
    var results = await Process.run(cmd,args.split(' '));
    log.finest('command exit code = ${results.exitCode} ');
    var s = await results.stdout;
    log.finest(s);
    var m = jsonDecode(s) as Map<String,Object>;
    var newMap = Map<String,Object>.from(config);
    newMap['credential'] = m['credential'];
    return config;
  }
}