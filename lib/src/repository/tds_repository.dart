import 'dart:convert';
import 'package:sqflite/sqflite.dart';

import '../dbs/data_base.dart';
import '../utils/text_utils.dart';
import '../http/tds_http.dart';
import '../http/errores_server.dart';

class TdsRepository {

  TextUtils textUtils = TextUtils();
  TdsHttp tdsHttp = TdsHttp();
  ErroresServer erroresServer = ErroresServer();

  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':''};

  /* Seccion de Bases de Datos */

  /*
   * @see TemplateBaseGral::_makeSave
   */
  Future<int> setTarjetaInBDLocal(Map<String, dynamic> tarjeta) async {

    int insertados = 0;

    Database db = await DBApp.db.abrir;
    Map<String, dynamic> tdSave = new Map();

    if(db.isOpen){
      
      List dataDb = await db.query('tds', where: 'td_td = ?', whereArgs: [tarjeta['td_td']]);
      if(dataDb.isEmpty){
        if(tarjeta.containsKey('td_td')) {
          tdSave = {
            'td_id'            : tarjeta['td_id'],
            'td_nombreEmpresa' : tarjeta['td_nombreEmpresa'],
            'td_giro'          : tarjeta['td_giro'],
            'td_lstLinks'      : json.encode(tarjeta['td_lstLinks']),
            'td_palclas'       : tarjeta['td_palclas'],
            'td_td'            : tarjeta['td_td']
          };
        }
        if(tdSave.isNotEmpty){
          await db.insert('tds', tdSave);
          tdSave = null;
        }else{
          return -1;
        }
      }
      dataDb = null;
    }
    
    List dataDb = await db.query('tds');
    insertados = dataDb.length;
    return insertados;
  }

  /*
   * @see FavoritosTdsPage::_getFavoritos
   */
  Future<List<Map<String, dynamic>>> getTarjetaInBDLocal() async {

    List<Map<String, dynamic>> tarjetas = new List();

    Database db = await DBApp.db.abrir;

    if(db.isOpen){

      List dataDb = await db.query('tds');
      if(dataDb.isNotEmpty){
        tarjetas = new List<Map<String, dynamic>>.from(dataDb);
      }
      dataDb = null;
    }

    return tarjetas;
  }

  /*
   * @see FavoritosTdsPage::_getFavoritos
   */
  Future<bool> hasTarjetaSaved(int id) async {

    Database db = await DBApp.db.abrir;

    if(db.isOpen){

      List<Map<String, dynamic>> has = await db.query('tds', where: 'td_id = ?', whereArgs: [id]);
      return (has.isNotEmpty) ? true : false;
    }

    return false;
  }

  ///
  Future<String> getNombreFile(String pathCompleto) async {

    List<String> pedazos = pathCompleto.split('/');
    String nombre = pedazos.last;
    if(nombre.contains('.pdf')){
      return nombre;
    }

    return 'nada';
  }

  /*
   * @see FavoritosTdsPage::_modalInferior
  */
  Future<bool> deleteTarjetaBy({String key, dynamic valor}) async {

    bool hecho;

    Database db = await DBApp.db.abrir;
    if(db.isOpen){
      int cant = await db.delete('tds', where: '$key = ?', whereArgs: [valor]);
      return (cant > 0) ? true : false;
    }
    return hecho;
  }

  /*
   * @see FavoritosTdsPage::_hacerBusqueda
   */
  Future<List<Map<String, dynamic>>> buscarTarjetas(String palabra) async {

    List<Map<String, dynamic>> tarjetas = new List();
    List<Map<String, dynamic>> resT = new List();
    
    String palabraServer = textUtils.crearCriterioDeBusqueda(palabra);

    List inTarjetas = await this.getTarjetaInBDLocal();
    if(inTarjetas.isNotEmpty) {
      resT = new List<Map<String, dynamic>>.from(inTarjetas);
      tarjetas = resT.where((element) => element.containsValue(palabra)).toList();
    }

    final reServer = await tdsHttp.buscarTarjetas(palabraServer);
    if(reServer.statusCode == 200) {
      List<dynamic>  res = json.decode(reServer.body);
      resT = List<Map<String, dynamic>>.from(res);
      tarjetas.addAll(resT);
    }else{
      this.result = await erroresServer.tratar(reServer);
    }
    resT = inTarjetas = null;
    return tarjetas;
  }

  /*
   * @see LoginSuccesPage::_getNombreFilePDF
   */
  Future<String> getNombreFilePDFDelUser(int idUser, String token) async {

    String nombreFilePDF = '0';

    final reServer = await tdsHttp.getNombreFilePDFDelUser(idUser, token);
    if(reServer.statusCode == 200) {
      Map<String, dynamic>  res = json.decode(reServer.body);
      nombreFilePDF = res['nombreFilePDF'];
    }else{
      this.result = await erroresServer.tratar(reServer);
    }
    return nombreFilePDF;
  }

  /*
   * @see LoginSuccesPage::_getNombreFilePDF
   */
  Future<String> getPalClasByIdTd(int idTd) async {

    String nombreFilePDF = '0';

    final reServer = await tdsHttp.getPalClasByIdTd(idTd);
    if(reServer.statusCode == 200) {
      Map<String, dynamic>  res = json.decode(reServer.body);
      nombreFilePDF = res['palabras'];
    }else{
      this.result = await erroresServer.tratar(reServer);
    }
    return nombreFilePDF;
  }

  /*
   * @see BaseIndex::_listenerControllerTap
   */
  Future<Map<String, dynamic>> getDataByNombreFile(String nombreFile) async {

    Map<String, dynamic> dataPdf = new Map();

    final reServer = await tdsHttp.getDataByNombreFile(nombreFile);
    if(reServer.statusCode == 200) {
      final data = json.decode(reServer.body);
     if(data.length != 0) {
        dataPdf = new Map<String, dynamic>.from(data);
     }
    }else{
      this.result = await erroresServer.tratar(reServer);
    }
    return dataPdf;
  }

  /*
   * @see AsesorGetData::_getAsesor
   */
  Future<Map<String, dynamic>> getDataAsesor(int idUser) async {

    Map<String, dynamic> dataAsesor = new Map();

    final reServer = await tdsHttp.getDataAsesor(idUser);
    if(reServer.statusCode == 200) {
      List data = json.decode(reServer.body);
      if(data.isNotEmpty) {
          dataAsesor = new Map<String, dynamic>.from(data[0]);
      }
    }else{
      this.result = await erroresServer.tratar(reServer);
    }
    return dataAsesor;
  }
}