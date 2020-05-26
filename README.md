# k8s_client - Dart Kubernetes client

This is just an experiment right now. Use at your own risk...

To generate the dart k8s api:

```a
mvn clean
mvn compile
```

## Fix ups:

Change ` newVal = <>  []..addAll(v)`

to: `newVal = <dynamic>  []..addAll(v)`

TODO:
Look at code generation options:
https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator-maven-plugin

The API is huge, and we might not want to generate all api calls:

* apisToGenerate - if we want to trim the apis down...
* modelsToGenerate - trim down the list of models.

Figure out how to implement support for CRDs

Implement parsing of kubeconfig, in-cluster config, etc.
