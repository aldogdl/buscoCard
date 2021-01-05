import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../repository/user_repository.dart';
import '../repository/tds_repository.dart';
import '../data_shared.dart';
import '../utils/on_camara_qr.dart';
import '../tema_gral.dart' as tema;
import 'widgets/menu_drawer.dart';
import 'widgets/input_buscador.dart';
import 'widgets/tarjetero_save_widget.dart';
import 'widgets/shared_file.widget.dart';
import 'widgets/alerts_varios.dart';
import 'widgets/card_view_widget.dart';
import 'widgets/bottom_navigation_my.dart';
import 'index_page.dart';
import 'tarjetero_page.dart';

class BaseIndex extends StatefulWidget {

  final Color solid;
  BaseIndex({Key key, this.solid}) : super(key: key);

  @override
  _BaseIndexState createState() => _BaseIndexState();
}

class _BaseIndexState extends State<BaseIndex> with SingleTickerProviderStateMixin {

  TdsRepository emTds = TdsRepository();
  AlertsVarios alertsVarios = AlertsVarios();
  UserRepository emUser = UserRepository();
  TarjeteroSaveWidget favoritosSaveWidget = TarjeteroSaveWidget();
  SharedFileWidget sharedFileWidget = SharedFileWidget();
  OnCamaraQr onCamaraQr = OnCamaraQr();

  GlobalKey<ScaffoldState> _keySkf = GlobalKey<ScaffoldState>();
  TabController _controllerTap;
  BuildContext _context;

  bool _isInit = false;
  bool _isInitCam = false;
  bool _showBtnQr = false;
  int _selectedIndex = 1;
  String _username;
  String _txtErrorQr = 'Espera un Momento por favor';
  Widget _widgetTapTwo;

  @override
  void initState() {

    this._controllerTap = TabController(length: 3, initialIndex: this._selectedIndex, vsync: this);
    this._controllerTap.addListener(() async => _listenerControllerTap());
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!this._isInit) {
      this._isInit = true;
      this._context = context;
      context = null;
      this._selectedIndex = Provider.of<DataShared>(this._context, listen: false).indexTap;
      if(this._selectedIndex != 1) {
        this._controllerTap.animateTo(this._selectedIndex);
      }
      this._username = Provider.of<DataShared>(this._context, listen: false).username;
      Provider.of<DataShared>(this._context, listen: false).setIndexTap(1);
      if(_widgetTapTwo == null){
        this._widgetTapTwo = _scanWidget();
      }
    }

    return Scaffold(
      key: this._keySkf,
      endDrawer: MenuDrawer(),
      endDrawerEnableOpenDragGesture: false,
      //appBar: _appBar(),
      body: _body(),
      bottomNavigationBar: BottomNavigationMy(),
      floatingActionButton: (this._selectedIndex == 1)
      ? _getFlotingWidget()
      : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
    );
  }

  ///
  Future<void> _initWidget(_) async {

    _cambiarSistemaColores();
    setState(() { });
  }

  ///
  Widget _getFlotingWidget() {

    if(this._username == 'Anónimo'){ return null; }
    return FloatingActionButton(
      elevation: 12,
      backgroundColor: Colors.white,
      onPressed: () async {

        String tdNombreFile = await emUser.getNombreFile();
        Provider.of<DataShared>(context, listen: false).setTdNombreFile(tdNombreFile);
        await sharedFileWidget.shareTd(context, 'local');

      },
      child: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          //color: Color(0xff322485)
          color: Color(0xff27A7E3)
        ),
        child: Icon(Icons.share, color: Colors.black, size: 20),
      ),
      isExtended: false,
      mini: true,
      tooltip: 'Compartir',
    );
  }

  ///
  Future<void> _listenerControllerTap() async {

    if(this._controllerTap.index == 2) {

      if(!this._isInitCam){
        this._isInitCam = true;
        this._showBtnQr = false;
        String res = await onCamaraQr.scan();
        _cambiarSistemaColores();

        if(res != 'ok') {

          //Abrir una URL cualquiera
          if(res.startsWith('openhttp')){

            List<String> pedazos = res.split('@');
            Provider.of<DataShared>(this._context, listen: false).setTdFromNet(pedazos[1]);
            Navigator.of(this._context).pushReplacementNamed('visor_url_qr_page');
            return false;

          }else{

            //Abrir el PDF de la Tarjeta Digital
            if(res.startsWith('pdf@')) {

              List<String> pedazos = res.split('@');
              List<String> url = pedazos[1].split('/');
              String uri = url.last;

              if(uri.endsWith('.pdf')) {
                Map<String, dynamic> data = await emTds.getDataByNombreFile(uri);
                
                if(data.isNotEmpty){
                  Provider.of<DataShared>(this._context, listen: false).setParaSave(data);
                  Provider.of<DataShared>(this._context, listen: false).setTdFromNet(pedazos[1]);
                  _viewCard(data);
                  //Navigator.of(this._context).pushNamedAndRemoveUntil('visor_td_page', (route) => false);
                }else{
                  this._txtErrorQr = 'Sin Datos para Visualizar';
                  this._showBtnQr = true;
                  setState(() {
                    this._widgetTapTwo = _scanWidget();
                  });
                }

              }else{
                this._txtErrorQr = 'Tarjeta Digital Invalida';
                this._showBtnQr = true;
                setState(() {
                  this._widgetTapTwo = _scanWidget();
                });
              }
            }else{
              this._txtErrorQr = res;
              this._showBtnQr = true;
              setState(() {
                this._widgetTapTwo = _scanWidget();
              });
            }
          }
        }

        this._isInitCam = false;
      }

    }else{
      setState(() {
        this._selectedIndex = this._controllerTap.index;
      });
    }
  }

  ///
  Widget _appBarCustom() {

    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Icon(Icons.search)
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(this._context).size.width * 0.4,
              height: MediaQuery.of(this._context).size.height * 0.06,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffFFFFFF)
              ),
              child: Center(
                child: InputBuscador(),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///
  Widget _appBar() {

    return AppBar(
      brightness: tema.baseBarIconColor,
      centerTitle: false,
      bottom: TabBar(
        labelPadding: EdgeInsets.only(left: 15),
        indicatorColor: const Color(0xffFFFFFF),
        controller: this._controllerTap,
        tabs: _getTaps(),
        isScrollable: false,
        onTap: (int index) async {
          this._selectedIndex = index;
        },
      ),
      leadingWidth: 0,
      title: Row(
        children: [
          Expanded(
            flex: 1,
            child: Icon(Icons.search)
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(this._context).size.width * 0.4,
              height: MediaQuery.of(this._context).size.height * 0.06,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xffFFFFFF)
              ),
              child: Center(
                child: InputBuscador(),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///
  List<Widget> _getTaps() {

    return [
      _getTap('Tarjetas', Icons.construction, Color(0xffFFFFFF)),
      _getTap('Mi Tarjeta', Icons.contact_phone, Color(0xff73F220)),
      _getTap('Lector QR', Icons.qr_code, Color(0xffFCC26D)),
    ];
  }

  ///
  Widget _getTap(String label, IconData icono, Color colorIcon) {

    double centerFactor = 1.3;
    if(MediaQuery.textScaleFactorOf(this._context) >= 1.15){
      centerFactor = 1.05;
    }

    Widget titulo = Center(
      widthFactor: (icono == Icons.construction) ? 1 : centerFactor,
      child: Text(
        label.toUpperCase(),
        textScaleFactor: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
        )
      ),
    );


    Widget indica = (icono == Icons.construction)
    ?
    Container(
      height: 20,
      width: 20,
      margin: EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Center(
        child: Consumer<DataShared>(
          builder: (_, dataShared, __) {
            return Text(
              '${dataShared.tarjInFav.length}',
              textScaleFactor: 1,
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12
              ),
            );
          },
        ),
      ),
    )
    :
    SizedBox(width: 0, height: 0);

    return Tab(
      child: Row(
        children: [
          (icono != Icons.construction) ? SizedBox(width: 0, height: 0) : titulo,
          (icono != Icons.construction) ? titulo : indica,
        ],
      ),
    );
  }

  ///
  Widget _body() {

    BoxDecoration boxDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xff0070B3).withAlpha(100),
          const Color(0xffFFFFFF)
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter
      )
    );

    if(widget.solid != null) {
      boxDecoration = BoxDecoration(
        color: widget.solid
      );
    }

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Container(
        width: MediaQuery.of(this._context).size.width,
        height: MediaQuery.of(this._context).size.height,
        decoration: boxDecoration,
        child: SafeArea(
          child: Column(
            children: [
              _appBarCustom()
            ],
          ),
        )
      )
    );
    // TabBarView(
    //       controller: this._controllerTap,
    //       children: [
    //         TarjeteroPage(),
    //         IndexPage(),
    //         this._widgetTapTwo,
    //       ],
    //     ),
  }
  
  ///
  Widget _scanWidget() {

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Text(
            this._txtErrorQr,
            textScaleFactor: 1,
            style: TextStyle(
              fontFamily: 'Lemon',
              fontSize: 15,
              color: Colors.red,
              fontWeight: FontWeight.bold
            ),
          ),
          (this._showBtnQr)
          ?
          _btnShowScan()
          :
          const SizedBox(height: 0, width: 0)
        ],
      ),
    );
  }

  ///
  void _viewCard(Map<String, dynamic> data) {

    this._widgetTapTwo = Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: CardViewWidget(dataTd: data),
        ),
        _btnShowScan()
      ],
    );

    setState(() { });
  }

  ///
  Widget _btnShowScan() {

    return RaisedButton(
      onPressed: () async {
        setState(() {
          this._widgetTapTwo = _scanWidget();
        });
        await _listenerControllerTap();
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xff0070B3),
      textColor: const Color(0xffFFFFFF),
      elevation: 0,
      child: Text(
        'Leer nuevamente un QR'
      ),
    );
  }

  ///
  void _cambiarSistemaColores() {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: tema.statusTopBarrSystem,
       statusBarIconBrightness: tema.baseBarIconColor,
       systemNavigationBarColor: tema.baseBarrBottomColor,
       systemNavigationBarIconBrightness: tema.baseBarIconColor
    ));

  }

}
