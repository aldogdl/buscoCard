import 'package:buscoCard/src/templates/widgets/alerts_varios.dart';
import 'package:buscoCard/src/templates/widgets/card_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import '../repository/tds_repository.dart';
import 'widgets/input_buscador.dart';
import 'widgets/menu_drawer.dart';


class ResultBusquedaPage extends StatefulWidget {
  ResultBusquedaPage({Key key}) : super(key: key);

  @override
  _ResultBusquedaPageState createState() => _ResultBusquedaPageState();
}

class _ResultBusquedaPageState extends State<ResultBusquedaPage> {

  TdsRepository emTds = TdsRepository();
  AlertsVarios alertsVarios = AlertsVarios();

  String _irToPage;
  bool _hasResultados = false;
  bool _isInit = false;
  BuildContext _context;
  List<Map<String, dynamic>> _tarjetas = new List();
  String _criterioBusqueda;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    if(!this._isInit) {
      this._isInit = true;
      this._context = context;
      this._criterioBusqueda = Provider.of<DataShared>(this._context, listen: false).criterioBusqueda;
      this._irToPage = Provider.of<DataShared>(this._context, listen: false).irToPage;
      Provider.of<DataShared>(this._context, listen: false).setIrToPage('result_busqueda_page');
      context = null;
      WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    }

    return Scaffold(
      endDrawer: MenuDrawer(),
      backgroundColor: const Color(0xffF1EEFC),
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xff0070B3),
        leadingWidth: 0,
        title: Row(
          children: [
            IconButton(
              padding: EdgeInsets.all(0),
              visualDensity: VisualDensity.comfortable,
              icon: Icon(Icons.home),
              onPressed: () async => Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false)
            ),
            Expanded(
              flex: 8,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                width: MediaQuery.of(this._context).size.width * 0.4,
                height: MediaQuery.of(this._context).size.height * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xffFFFFFF)
                ),
                child: InputBuscador(),
              ),
            )
          ],
        ),
      ),
      body: WillPopScope(
        onWillPop: () async => await _irTo(),
        child: _buscando(),
      ),
    );
  }

  ///
  Future<void> _initWidget(_) async {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: const Color(0xff0070B3).withAlpha(100),
      systemNavigationBarColor: const Color(0xffFFFFFF),
      systemNavigationBarIconBrightness: Brightness.dark
    ));
    setState(() { });
  }
  
  ///
  Widget _buscando() {

    return FutureBuilder(
      future: _hacerBusqueda(),
      builder: (_, AsyncSnapshot snapshot) {

        if(snapshot.connectionState == ConnectionState.done) {

          if(this._tarjetas.isEmpty) {
            return _nadaQueVer();
          }

          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${this._tarjetas.length} Resultados de ',
                      textScaleFactor: 1,
                      style: TextStyle(
                        fontSize: 15
                      ),
                    ),
                    Text(
                      '${this._criterioBusqueda.toUpperCase()}',
                      textScaleFactor: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(this._context).size.height * 0.80,
                child: _resultadosDeBusqueda()
              )
            ],
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(
            child: SizedBox(
              width: 40, height: 40,
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
    );
  }

  ///
  Widget _resultadosDeBusqueda() {

    if(this._tarjetas.isNotEmpty) {
      return _listaDeTarjetas();
    }
    return const SizedBox(height: 0);
  }

  ///
  Widget _listaDeTarjetas() {

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 10),
      itemCount: this._tarjetas.length,
      itemBuilder: (_, int index) {

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CardViewWidget(dataTd: this._tarjetas[index]),
        );

      },
    );
  }

  ///
  Widget _nadaQueVer() {

    String msg = 'Por el momento, nada encontrado con el criterio de búsqueda ${this._criterioBusqueda.toUpperCase()}\n\n'+
    'Revisa tu solicitud o ingresa algún sinónimo de ${this._criterioBusqueda.toUpperCase()}';

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 30),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: BorderRadius.circular(20)
        ),
        child: Text(
          msg,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.red
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _hacerBusqueda() async {

    if(this._criterioBusqueda != null) {
      if(this._criterioBusqueda.isEmpty) {
        this._criterioBusqueda = 'tarjetas';
      }
    }else{
      this._criterioBusqueda = 'tarjetas';
    }

    if(!this._hasResultados) {
      this._tarjetas = await emTds.buscarTarjetas(this._criterioBusqueda);
      this._hasResultados = true;
    }
  }

  ///
  Future<bool> _irTo() async {

    Navigator.of(this._context).pushNamedAndRemoveUntil(this._irToPage, (route) => false);
    return Future.value(true);
  }
}