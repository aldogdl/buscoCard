import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import 'widgets/alerts_varios.dart';
import '../repository/user_repository.dart';
import '../repository/tds_repository.dart';

class LoginSuccesPage extends StatefulWidget {
  LoginSuccesPage({Key key}) : super(key: key);

  @override
  _LoginSuccesPageState createState() => _LoginSuccesPageState();
}

class _LoginSuccesPageState extends State<LoginSuccesPage> {

  UserRepository emUser = UserRepository();
  TdsRepository emTds = TdsRepository();
  AlertsVarios alertsVarios = AlertsVarios();

  bool _isInit = false;
  BuildContext _context;

  String _pathDoc = 'Path';
  String _nombreFile;

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._context = context;
      context = null;
    }

     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Color(0xff0070B3).withAlpha(100),
       systemNavigationBarColor: Color(0xffFFFFFF),
       systemNavigationBarIconBrightness: Brightness.dark
    ));

    return Scaffold(
      body: WillPopScope(
        onWillPop: () => Future.value(false),
        child: Container(
          width: MediaQuery.of(this._context).size.width,
          height: MediaQuery.of(this._context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xff0070B3).withAlpha(50),
                const Color(0xffFFFFFF),
                const Color(0xffFFFFFF)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          ),
          child: _body(),
        ),
      ),
    );
  }

  ///
  Widget _body() {

    return FutureBuilder(
      future: _getNombreFilePDFDelUser(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.connectionState == ConnectionState.done) {
          if(this._nombreFile != null) {
            return _descargarPdf();
          }
        }
        return Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: alertsVarios.procesandoFlat(
              body: 'Buscando tu Tarjeta Digital.'
            ),
          )
        );
      }
    );
  }

  ///
  Future<String> _getNombreFilePDFDelUser() async {

    String username = Provider.of<DataShared>(this._context, listen: false).username;
    int idUser = await emUser.getIdUserFromDBLocal(username);
    if(idUser != 0) {
      this._nombreFile = await emTds.getNombreFilePDFDelUser(idUser, Provider.of<DataShared>(this._context, listen: false).tokenServer);
      if(this._nombreFile == '0') {
        if(emTds.result['abort']) {
          await alertsVarios.showMsgError(context: this._context, titulo: emTds.result['msg'], body: emTds.result['body']);
        }
      }
    }
    return '0';
  }

  /// Localizamos el path de Documentos de la app.
  /// 
  Future<String> get _localPath async {

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  ///
  Widget _descargarPdf() {

    return FutureBuilder(
      future: _localFile,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: alertsVarios.procesandoFlat(
              body: 'Estamos configurando tu nueva app, espera un momento, por favor.'
            ),
          )
        );
      }
    );
  }

  ///
  Future<void> get _localFile async {

    bool goIndex = false;
    Provider.of<DataShared>(this._context, listen: false).setIndexTap(1);
    
    this._pathDoc = await _localPath;
    if(this._nombreFile == '0'){
      Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
      return;
    }

    File pdf = File('${this._pathDoc}/${this._nombreFile}');
    if(!await pdf.exists()){
      String username = Provider.of<DataShared>(this._context, listen: false).username;
      bool dowload = await emUser.downloadPdfByUser(this._pathDoc, this._nombreFile, username);
      if(!dowload){
        String body = 'No se pudo descargar ni almacenar tu Tarjeta Digital, inténtalo nuevamente por favor';
        await alertsVarios.showMsgError(context: this._context, titulo: 'Error al DESCARGAR', body: body);
      }else{
        goIndex = true;
      }
    }else{
      goIndex = true;
    }

    if(goIndex){
      Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
    }
    return;
  }


}