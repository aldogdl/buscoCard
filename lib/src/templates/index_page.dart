import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import '../repository/user_repository.dart';
import '../repository/tds_repository.dart';
import 'base_index.dart';
import 'widgets/tienes_negocio_widget.dart';
import '../singletons/pdf_singleton.dart';

class IndexPage extends StatefulWidget {
  IndexPage({Key key}) : super(key: key);

  @override
  _IndexPageState createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {

  BaseIndex templateBaseGral = BaseIndex();
  UserRepository emUser = UserRepository();
  TdsRepository emTds = TdsRepository();
  PdfSingleton pdfSingleton = PdfSingleton();

  String _nombreFile;
  String _pathDoc = 'Path';
  String _username = 'Anónimo';
  bool _isLoaderPdf = false;
  bool _isInit = false;
  String _msgTxt = '¡Esperala muy pronto!';
  BuildContext _context;

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._isInit = true;
      this._username = Provider.of<DataShared>(context, listen: false).username;
      this._context = context;
      context = null;
      Provider.of<DataShared>(this._context, listen: false).setIndexTap(1);
      Provider.of<DataShared>(this._context, listen: false).setIrToPage('base_index_page');
    }

    return _body();
  }

  ///
  Widget _body() {
    
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: (this._username == 'Anónimo')
      ? _indexWhitOutToken()
      : _indexWithToken()
    );
  }

  ///
  Widget _indexWithToken() {

    if(pdfSingleton.pdf != null) {
      return PDF.file(
        pdfSingleton.pdf,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      );
    }

    return Center(
      child: FutureBuilder(
        future: _localFile(),
        builder: (_, AsyncSnapshot snapshot) {

          if(snapshot.connectionState == ConnectionState.done) {
            if(pdfSingleton.pdf != null) {
              try {
                return PDF.file(
                  pdfSingleton.pdf,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  placeHolder: Image.asset(
                    'assets/images/send_data.png',
                    height: 200,
                    width: 100
                  ),
                );
              } catch (e) {
                return Text('Error al Visualizar TD.');
              }

            }else{
              return _tdEnProceso();
            }
          }

          return Center(
            child: SizedBox(
              height: 40, width: 40,
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  ///
  Widget _tdEnProceso() {

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(this._context).size.width * 0.7,
            height: MediaQuery.of(this._context).size.width * 0.7,
            decoration: BoxDecoration(
              color: Color(0xffFFFFFF),
              border: Border.all(
                width: 10,
                color: Color(0xff0070B3)
              ),
              borderRadius: BorderRadius.circular(300)
            ),
            child: Icon(Icons.thumb_up, size: MediaQuery.of(this._context).size.width * 0.4, color: Color(0xff0070B3)),
          ),
          const SizedBox(height: 20),
          Text(
            'Tu Tarjeta esta en Proceso',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Lemon',
              fontSize: 20,
              letterSpacing: 2
            ),
          ),
          const SizedBox(height: 7),
          Text(
            this._msgTxt,
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),
          ),
          const SizedBox(height: 15),
          RaisedButton(
            onPressed: () async => await _revisarExistenciaTd(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              child: const Text(
                'REVISAR EXISTENCIA',
                textScaleFactor: 1,
                style: TextStyle(
                  fontFamily: 'Lemon',
                  letterSpacing: 2
                ),
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)
            ),
            color: const Color(0xffFFFFFF),
          )
        ],
      ),
    );
  }

  ///
  Widget _indexWhitOutToken() {

      return Center(
      child: ListView(
        padding: EdgeInsets.all(20),
        shrinkWrap: true,
        children: [
          const SizedBox(height: 10),
          TienesUnNegocioWidget()
        ],
      ),
    );
  }

  /// Localizamos el path de Documentos de la app.
  Future<String> get _localPath async {

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  ///
  Future<void> _localFile() async {

    bool error = false;
    if(!this._isLoaderPdf){
      this._nombreFile = await emUser.getNombreFile();
      if(this._nombreFile == '0') {
        pdfSingleton.pdf = null;
        return;
      }
      this._pathDoc = await _localPath;
      Provider.of<DataShared>(context, listen: false).setTdNombreFile(this._nombreFile);

      try {
        pdfSingleton.pdf = File('${this._pathDoc}/${this._nombreFile}');
      } catch (e) {
        error = true;
      }

      if(!await pdfSingleton.pdf.exists()) {
        error = true;
      }

      if(error) {
        pdfSingleton.pdf = null;
        this._isLoaderPdf = false;
      }else{
        this._isLoaderPdf = true;
      }
    }
  }

  ///
  Future<void> _revisarExistenciaTd() async {

    String username = Provider.of<DataShared>(this._context, listen: false).username;
    String tokenServer = Provider.of<DataShared>(this._context, listen: false).tokenServer;
    if(tokenServer == null) {
      Map<String, dynamic> dataUser = await emUser.getDataUserForGetToken();
      tokenServer = await emUser.getTokenByUser(dataUser);
      if(tokenServer.length > 20) {
        Provider.of<DataShared>(this._context, listen: false).setTokenServer(tokenServer);
      }
    }
    int idUser = await emUser.getIdUserFromDBLocal(username);

    if(idUser != 0){

      this._msgTxt = 'Revisando Existencia...';
      
      this._nombreFile = await emTds.getNombreFilePDFDelUser(idUser, tokenServer);
      if(this._nombreFile == '0') {
        this._msgTxt = 'UPS!, todavía en PROCESO';
        Future.delayed(Duration(seconds: 3), (){
          setState(() {
            this._msgTxt = '¡Esperala muy pronto!';
          });
        });
      }else{

        this._pathDoc = await _localPath;
        bool dowload = await emUser.downloadPdfByUser(this._pathDoc, this._nombreFile, username);
        if(!dowload){
          this._msgTxt = 'No se pudo descargar ni almacenar tu Tarjeta Digital, inténtalo nuevamente por favor';
        }else{
          await emUser.updateNombreFile(this._nombreFile, username);
          this._isLoaderPdf = false;
        }
      }
    }else{
      this._msgTxt = 'ERROR, No se encontro tu ID.\n\nInténtalo nuevamente.';
    }
    setState(() {});
  }

}