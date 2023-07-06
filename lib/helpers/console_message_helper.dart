import 'package:flutter/foundation.dart';

class Console{
  static log(dynamic data){
    if (kDebugMode) {
      print(data);
    }

  }
}