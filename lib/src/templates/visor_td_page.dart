import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import '../repository/tds_repository.dart';
import 'widgets/shared_file.widget.dart';
import 'widgets/tarjetero_save_widget.dart';
import 'widgets/menu_drawer.dart';
import 'base_index.dart';

class VisorTdPage extends StatefulWidget {
  VisorTdPage({Key key}) : super(key: key);

  @override
  _VisorTdPageState createState() => _VisorTdPageState();
}

class _VisorTdPageState extends State<VisorTdPage> {

  BaseIndex baseIndex = BaseIndex();
  TdsRepository emTds = TdsRepository();
  SharedFileWidget sharedFileWidget = SharedFileWidget();

  bool _isInit = false;
  bool _showSave = true;
  BuildContext _context;
  String _pdf;
  String _irToPage = 'index_page';
  int _indexPage = 1;
  Map<String, dynamic> _paraSalvar = new Map();
  Map<String, dynamic> _lstIcosBac = {
    'result_busqueda_page': Icons.search,
    'base_index_page' : Icons.home
  };

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_iniWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._isInit = true;
      this._context = context;
      context = null;
      this._paraSalvar = Provider.of<DataShared>(this._context, listen: false).paraSave;
      this._irToPage = Provider.of<DataShared>(this._context, listen: false).irToPage;
      this._indexPage = Provider.of<DataShared>(this._context, listen: false).indexTap;
      WidgetsBinding.instance.addPostFrameCallback(_iniWidget);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xff0070B3),
        leadingWidth: 0,
        toolbarHeight: 65,
        title: Row(
          children: [
            IconButton(
              icon: Icon(
                this._lstIcosBac.containsKey(this._irToPage)
                ?
                (this._indexPage == 1) ? this._lstIcosBac[this._irToPage] : Icons.favorite
                : Icons.home),
              onPressed: () async => await _irTo()
            ),
            Expanded(child: SizedBox(width: 20)),
            (this._showSave)
            ?
            Column(
              children: [
                IconButton(
                  padding: EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.favorite_border),
                  onPressed: () async => await _saveTarjeta()
                ),
                Text(
                  'Guardar',
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 10
                  ),
                )
              ],
            )
            :const SizedBox(width: 30),

            const SizedBox(width: 30),
            Column(
              children: [
                IconButton(
                  padding: EdgeInsets.all(0),
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.share),
                  onPressed: () async => await sharedFileWidget.shareTd(context, 'visor')
                ),
                Text(
                  'Compartir',
                  textScaleFactor: 1,
                  style: TextStyle(
                    fontSize: 10
                  ),
                )
              ],
            ),
          ],
        ) 
      ),
      endDrawer: MenuDrawer(),
      backgroundColor: const Color(0xff0070B3),
      body: _body(),
    );
  }

  ///
  Future<void> _iniWidget(_) async {

    Provider.of<DataShared>(this._context, listen: false).setIrToPage('base_index_page');
    bool has = await emTds.hasTarjetaSaved(this._paraSalvar['td_id']);
    this._showSave = (has) ? false : true;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff0070B3).withAlpha(100),
      systemNavigationBarColor: Color(0xffFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark
    ));

    setState(() {});
  }

  ///
  Widget _body() {

    return WillPopScope(
      onWillPop: () async => _irTo(),
      child: Center(
        child: FutureBuilder(
          future: _localFile(),
          builder: (_, AsyncSnapshot snapshot) {

            if(snapshot.connectionState == ConnectionState.done) {
              
              if(this._pdf != null) {
                return PDF.network(
                  this._pdf,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  placeHolder: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/send_data.jpg',
                        ),
                        Container(
                          color: Colors.white,
                          child: Column(
                            children: [
                              LinearProgressIndicator(),
                              Padding(
                                padding: EdgeInsets.all(10),
                                child: Text(
                                  'Recuperando Datos',
                                  textScaleFactor: 1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
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
      )
    );
  }

  ///
  Future<void> _localFile() async {

    if(this._pdf != null){  return; }

    this._pdf = Provider.of<DataShared>(this._context, listen: false).tdFromNet;
    String nombreFile = await emTds.getNombreFile(this._pdf);
    if(nombreFile.endsWith('.pdf')) {
      Provider.of<DataShared>(this._context, listen: false).setTdNombreFile(nombreFile);
    }
    return;
  }

  ///
  Future<void> _saveTarjeta() async {

    showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (_) => TarjeteroSaveWidget(contextParent: this._context, paraSalvar: this._paraSalvar)
    );
  }

  ///
  Future<bool> _irTo() async {

    Navigator.of(this._context).pushNamedAndRemoveUntil(this._irToPage, (route) => false);
    return true;
  }


}