import 'dart:convert';

import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class UserHttp {

  String _uriBase = 'apis/tds/app/';

  /*
  * @see UserRepository
  */

  /// ::getTokenByUser
  Future<http.Response> getTokenByUser(Map<String, dynamic> data) async {

    Uri uri = Uri.parse('${globals.base}/login_tds/login_check');
    final req = http.MultipartRequest('POST', uri);
    req.fields['_usname'] = data['_usname'];
    req.fields['_uspass'] = data['_uspass'];

    return await http.Response.fromStream(await req.send());
  }

  /// ::cambiarPass
  Future<http.Response> cambiarPass(Map<String, dynamic> data, String token) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBase}cambiar-pass-user/');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $token';
    req.fields['data'] = json.encode(data);

    return await http.Response.fromStream(await req.send());
  }

  ///::getDataUserFromServer
  Future<http.Response> getDataUserFromServer(String username, String tokenServer) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBase}get-data-user/');
    final req = http.MultipartRequest('POST', uri);
    req.headers['Authorization'] = 'Bearer $tokenServer';
    req.fields['username'] = username;
    return await http.Response.fromStream(await req.send());
  }

  ///::downloadPdfByUser
  Future<http.Response> getPDFByUser(String nombreFile) async {

    Uri uri = Uri.parse('${globals.baseTds}/$nombreFile');
    
    final req = http.MultipartRequest('GET', uri);
    return await http.Response.fromStream(await req.send());
  }
}

