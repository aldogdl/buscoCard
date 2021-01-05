import 'dart:convert';

import 'package:http/http.dart' as http;

class ErroresServer {

  Map<String, dynamic> _result = {'abort':true, 'msg':'Error', 'body': 'Error no Determinado'};

  ///
  Future<Map<String, dynamic>> tratar(http.Response error) async {

    final mapaErr = json.decode(error.body);

    assert((){
      print(mapaErr);
      return true;
    }());

    if(mapaErr['message'] == 'JWT Token not found') {
      this._result['msg'] =  'No Autorizado';
      this._result['body'] =  'No se ha detectado un Token Valido para el Servidor';
      return this._result;
    }

    if(error.reasonPhrase.contains('Unauthorized')){
      this._result['msg'] =  'No Autorizado';
      this._result['body'] =  'No estas autorizado para ésta Sección o tus Credenciales no son Validas';
    }

    return this._result;
  }

}