import 'package:http/http.dart' as http;
import '../globals.dart' as globals;

class TdsHttp {

  String _uriBase = 'apis/tds/app/';
  String _uriBasePublic = 'app/public/';

  /*
   * @see TdsRepository::buscarTarjetasFrom
   */
  Future<http.Response> buscarTarjetas(String palabra) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBasePublic}$palabra/buscar-tarjetas');
    final req = http.MultipartRequest('GET', uri);
    return await http.Response.fromStream(await req.send());
  }

  /*
   * @see TdsRepository::getPalClasByIdTd
   */
  Future<http.Response> getPalClasByIdTd(int idTd) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBasePublic}$idTd/get-palclas-by-idtd/');
    final req = http.MultipartRequest('GET', uri);
    return await http.Response.fromStream(await req.send());
  }

  /*
   * @see TdsRepository::buscarTarjetasFrom
   */
  Future<http.Response> getNombreFilePDFDelUser(int idUser, String token) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBase}$idUser/get-nombre-file-pdf-user/');
    var req = http.MultipartRequest('GET', uri);
    req.headers['Authorization'] = 'Bearer $token';
    return await http.Response.fromStream(await req.send());
  }

  /*
   * @see TdsRepository::getDataByNombreFile
   */
  Future<http.Response> getDataByNombreFile(String nombreFile) async {
    
    Uri uri = Uri.parse('${globals.base}/${this._uriBasePublic}$nombreFile/get-data-by-nombre-file/');
    var req = http.MultipartRequest('GET', uri);
    return await http.Response.fromStream(await req.send());
  }

  /*
   * @see TdsRepository::getDataAsesor
   */
  Future<http.Response> getDataAsesor(int idUser) async {

    Uri uri = Uri.parse('${globals.base}/${this._uriBasePublic}$idUser/get-data_asesor/');
    var req = http.MultipartRequest('GET', uri);
    return await http.Response.fromStream(await req.send());
  }
}