import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:sqflite/sqflite.dart';

import '../dbs/data_base.dart';
import '../http/user_http.dart';
import '../http/errores_server.dart';

class UserRepository {

  ErroresServer errores = ErroresServer();
  UserHttp userHttp = UserHttp();
  Map<String, dynamic> result = {'abort':false, 'msg':'ok', 'body':''};

  /* Seccion de Bases de Datos */

  /*
   * @see InitConfigPage::_getTokenFromServer
   */
  Future<Map<String, dynamic>> getDataUserForGetToken() async {

    Map<String, dynamic> user = new Map();

    Database db = await DBApp.db.abrir;
    if(db.isOpen){

      List dataDb = await db.query('user');
      if(dataDb.isNotEmpty){
        user = {
          '_usname' : dataDb.first['u_username'],
          '_uspass' : dataDb.first['u_password'],
        };
      }
      dataDb = null;
    }
    return user;
  }

  /*
   * @see InitConfigPage::_revisandoCredenciales
   */
  Future<bool> setDataUserFromServerInDBLocal(Map<String, dynamic> dataUserFromServer) async {

    int insertados = 0;
    Database db = await DBApp.db.abrir;
    if(db.isOpen){
      if(!dataUserFromServer.containsKey('u_nombreFile')){
        dataUserFromServer['u_nombreFile'] = '0';
      }
      dataUserFromServer['u_username'] = dataUserFromServer['u_username'].toString().toUpperCase();
      List dataDb = await db.query('user');
      if(dataDb.isEmpty){
        insertados = await db.insert('user', dataUserFromServer);
      }
      dataDb = null;
    }
    if(insertados == 0) {
      this.result['abort'] = true;
      this.result['msg'] = 'ERROR AL GUARDAR';
      this.result['body'] = 'No se pudo guardar los datos, intentalo nuevamente por favor.';
    }
    return (insertados > 0) ? true : false;
  }

  /*
   * @see InitConfigPage::_revisandoCredenciales
   */
  Future<int> getIdUserFromDBLocal(String username) async {

    int idUser = 0;
    Database db = await DBApp.db.abrir;
    if(db.isOpen){
      List dataDb = await db.query('user', where: 'u_username = ?', whereArgs: [username]);
      if(dataDb.isNotEmpty){
        idUser =  dataDb.first['u_id'];
      }
      dataDb = null;
    }

    return idUser;
  }

  /*
   * @see AsesorGetData::_getAsesor
   */
  Future<Map<String, dynamic>> getDataUserFromDBLocal() async {

    Map<String, dynamic> user = new Map();
    Database db = await DBApp.db.abrir;
    if(db.isOpen){
      List dataDb = await db.query('user');
      if(dataDb.isNotEmpty){
        user =  new Map<String, dynamic>.from(dataDb.first);
      }
      dataDb = null;
    }

    return user;
  }

  /*
   * @see this->
  */
  Future<bool> updateNombreFile(String nombreFile, String username) async {

    Database db = await DBApp.db.abrir;
    if(db.isOpen){

      List dataDb = await db.query('user');
      if(dataDb.isNotEmpty){
        int insertados = await db.update('user', {'u_nombreFile':nombreFile}, where: 'u_username = ?', whereArgs: [username]);
        return (insertados > 0) ? true : false;
      }else{
        return false;
      }
    }
    return false;
  }

  /*
   * @see ChangePassPage::_sendData
  */
  Future<bool> cambiarPassInDBLocal(String newPass) async {

    Database db = await DBApp.db.abrir;
    if(db.isOpen){

      List dataDb = await db.query('user');
      if(dataDb.isNotEmpty){
        int insertados = await db.update('user', {'u_password':newPass}, where: 'u_id = ?', whereArgs: [dataDb.first['u_id']]);
        return (insertados > 0) ? true : false;
      }else{
        return false;
      }
    }
    return false;
  }

  /*
   * @see LoginSuccesPage::_localFile
  */
  Future<String> getNombreFile() async {

    Database db = await DBApp.db.abrir;
    if(db.isOpen){

      List dataDb = await db.query('user');
      if(dataDb.isNotEmpty){
        return dataDb.first['u_nombreFile'];
      }
    }
    return null;
  }

  /* Seccion REMOTA */

  ///@see ChangePassPage::_sendData
  Future<bool> cambiarPass(Map<String, dynamic> dataUser, String token) async {

    bool resultado;
    final reServer = await userHttp.cambiarPass(dataUser, token);
    if(reServer.statusCode == 200) {
      Map<String, dynamic> res = new Map<String, dynamic>.from(json.decode(reServer.body));
      resultado = res['change'];
      res = null;
    }else{
      this.result = await errores.tratar(reServer);
      resultado = false;
    }
    return resultado;
  }

  ///@see InitConfigPage::_revisandoCredenciales
  ///@see LoginPage::_sendData
  Future<String> getTokenByUser(Map<String, dynamic> dataUser) async {

    String resultado = 'err';
    final reServer = await userHttp.getTokenByUser(dataUser);
    if(reServer.statusCode == 200) {
      Map<String, dynamic> res = new Map<String, dynamic>.from(json.decode(reServer.body));
      resultado = res['token'];
      res = null;
    }else{
      this.result = await errores.tratar(reServer);
    }
    return resultado;
  }

  ///@see LoginPage::_getDataUserFromServer
  Future<Map<String, dynamic>> getDataUserFromServer(String username, String tokenServer) async {

    Map<String, dynamic> resultado = new Map();

    final reServer = await userHttp.getDataUserFromServer(username, tokenServer);
    if(reServer.statusCode == 200) {
      resultado = new Map<String, dynamic>.from(json.decode(reServer.body));
    }else{
      this.result = await errores.tratar(reServer);
    }
    return resultado;
  }

  /// @see LoginSuccesPage::_localFile
  Future<bool> downloadPdfByUser(String pathToStoragePDF, String nombreFile, String username) async {

    final reServer = await userHttp.getPDFByUser(nombreFile);
    if(reServer.statusCode == 200) {
      if(reServer.bodyBytes.length > 50) {
        
        File pdf = File('$pathToStoragePDF/$nombreFile');
        try {
          pdf = await pdf.create(recursive: true);
          await pdf.writeAsBytes(reServer.bodyBytes);
          await updateNombreFile(nombreFile, username);
          return true;

        } catch (e) {
          return false;
        }

      }else{
        this.result['abort'] = true;
        this.result['msg'] = 'ERROR DE DESCARGA';
        this.result['body'] = 'No se descargo correctamente tu Tarjeta Digital, inténtalo nuevamente por favor.';
        return false;
      }
    }else{
      this.result = await errores.tratar(reServer);
    }

    return false;
  }

  /// @see LoginSuccesPage::_localFile
  Future<Uint8List> downloadPdfByNombreFile(String nombreFile) async {

    final reServer = await userHttp.getPDFByUser(nombreFile);
    if(reServer.statusCode == 200) {
      if(reServer.bodyBytes.length > 50) {
        return reServer.bodyBytes;
      }else{
        this.result['abort'] = true;
        this.result['msg'] = 'ERROR DE DESCARGA';
        this.result['body'] = 'No se descargo correctamente tu Tarjeta Digital, inténtalo nuevamente por favor.';
        return new List();
      }
    }else{
      this.result = await errores.tratar(reServer);
    }

    return new List();
  }

}

