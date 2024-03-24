import 'dart:convert';
import 'package:crypto/crypto.dart';

String getSHA256(String str, {String firstStr = '', String lastStr = ''}) {
  str = firstStr + str + lastStr;
  var bytes = utf8.encode(str);
  var result = sha256.convert(bytes);
  return result.toString();
}
