import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_shared.dart';
import '../repository/tds_repository.dart';
import 'widgets/menu_drawer.dart';
import 'base_index.dart';
import 'widgets/input_buscador.dart';


class VisorUrlQrPage extends StatefulWidget {
  VisorUrlQrPage({Key key}) : super(key: key);

  @override
  _VisorUrlQrPageState createState() => _VisorUrlQrPageState();
}

class _VisorUrlQrPageState extends State<VisorUrlQrPage> {

  BaseIndex templateBaseGral = BaseIndex();
  TdsRepository emTds = TdsRepository();

  bool _isInit = false;
  String _showErr = 'Para ver de que se trata, presiona el Bóton "ABRIR URL". Ésto abrirá tu navegador determinado';
  BuildContext _context;
  String _url;


  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_iniWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._context = context;
      context = null;
      this._url = Provider.of<DataShared>(this._context, listen: false).tdFromNet;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xff0070B3),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async => await _irTo()
        ),
        leadingWidth: 30,
        title: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          height: MediaQuery.of(this._context).size.height * 0.06,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xffFFFFFF)
          ),
          child: InputBuscador(),
        ) 
      ),
      endDrawer: MenuDrawer(),
      body: _body(),
    );
  }

  ///
  Widget _body() {

    return WillPopScope(
      onWillPop: () async => await _irTo(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xff0070B3).withAlpha(100),
                    const Color(0xffFFFFFF)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                border: Border.all(
                  color: Colors.blueGrey,
                ),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Column(
                children: [
                  Icon(Icons.network_check, size: 120, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(
                    'El lector detectó la entrada a una Página Web.',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xffFFFFFF),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${this._showErr}',
                    textScaleFactor: 1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      width: MediaQuery.of(this._context).size.width,
                      child: RaisedButton(
                        onPressed: () async {
                          await _openNavegador();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)
                        ),
                        color: const Color(0xff0070B3),
                        textColor: const Color(0xffFFFFFF),
                        child: Text(
                          'ABRIR URL',
                          textScaleFactor: 1,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${this._url}',
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13
                ),
              ),
            )
          ],
        ),
      )
    );
  }

  ///
  Future<void> _openNavegador() async {

    if (await canLaunch(this._url)) {
      await launch(this._url);
    } else {
      setState(() {
        this._showErr = 'No se pudo abrir el navegador, Inténtalo nuevamente, por favor.';
      });
    } 
  }

  ///
  Future<void> _iniWidget(_) async {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: Color(0xff0070B3).withAlpha(100),
       systemNavigationBarColor: Color(0xff0070B3),
       systemNavigationBarIconBrightness: Brightness.light
    ));
    setState(() {});
  }

  ///
  Future<bool> _irTo() async {

    Provider.of<DataShared>(this._context, listen: false).setIndexTap(0);
    Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
    return true;
  }


}