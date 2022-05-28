import 'dart:convert';

import 'package:http/http.dart' as http;
import 'server.dart' as server;

class UsersTools {
  Future<dynamic> signUpUser(String e, String p) async {
    String linkTemp = server.link;
    final respuesta = await http.post(Uri.parse("$linkTemp/signUp"),
        body: postDataUser(e, p),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        });

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body)['result'];
    } else {
      print("Error con la respuesta");
    }
  }

  Future<dynamic> signInUser(String e, String p) async {
    String linkTemp = server.link;
    final respuesta = await http.post(Uri.parse("$linkTemp/signIn"),
        body: postDataUser(e, p),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
        });

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body)['result'];
    } else {
      print("Error con la respuesta");
    }
  }

  String postDataUser(String email, String password) {
    Map<String, dynamic> map = {"email": email, "password": password};
    return json.encode(map);
  }
}
