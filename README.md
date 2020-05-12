# k8s_client - Dart Kubernetes client

This is just an experiment right now. Use at your own risk...

To generate the dart k8s api:

```a
mvn clean
mvn compile
```

A couple of manual fix ups are needed (TBD):

Edit k8s_api/lib/api.dart and add:
```
import 'package:k8s_custom_types/k8s_custom_types.dart';

```

Edit k8s_api/pubspec.yaml and add the following dependency:
```
k8s_custom_types:
    path: ../k8s_custom_types
```
