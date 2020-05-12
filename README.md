# k8s_client - Dart Kubernetes client

This is just an experiment right now. Use at your own risk...

To generate the dart k8s api:

```a
mvn clean
mvn compile
```

One minor fixup is needed  (TBD):

Edit k8s_api/lib/api.dart and add:
```
import 'package:k8s_custom_types/k8s_custom_types.dart';
```

Options:


https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator-maven-plugin



apisToGenerate - if we want to trim the apois down...
modelsToGenerate

