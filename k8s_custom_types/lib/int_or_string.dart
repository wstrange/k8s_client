
// this is a kubernetes style custom class
class IntOrString {
  String value;

  static List<IntOrString> listFromJson(dynamic json) {
    return (json as List)
        .map((e) => IntOrString()..value = e.toString())
        .toList();
  }

  IntOrString([this.value]);

 IntOrString.fromJson(dynamic json) {
    if( json is String) {
      this.value = json;
    }
    else
    if( json is int) {
      this.value = '$json';
    }
    else {
      throw Exception('Value is not int or string. json=$json');
    }
  }
}