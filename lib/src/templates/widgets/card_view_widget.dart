import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../repository/tds_repository.dart';
import '../../data_shared.dart';
import '../../globals.dart' as globals;
import 'tarjetero_save_widget.dart';
import 'shared_file.widget.dart';
import 'alerts_varios.dart';

class CardViewWidget extends StatefulWidget {

  final String callFrom;
  final Map<String, dynamic> dataTd;
  CardViewWidget({this.dataTd, this.callFrom});

  @override
  _CardViewWidgetState createState() => _CardViewWidgetState();
}

class _CardViewWidgetState extends State<CardViewWidget> with SingleTickerProviderStateMixin {

  TdsRepository emTds = TdsRepository();
  SharedFileWidget sharedFileWidget = SharedFileWidget();
  AlertsVarios alertsVarios = AlertsVarios();

  bool _isInit = false;
  BuildContext _context;
  String _nombreFile = '0';
  IconData _icoFav;
  Color _colorFav;
  bool _isInFav = false;
  List<int> _lstInFavs = new List();
  AnimationController _animationController;

  @override
  void initState() {
    this._animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      value: 1,
      vsync: this
    );
    this._icoFav = FontAwesomeIcons.heart;
    this._colorFav = Colors.blue;
    super.initState();
  }

  @override
  void dispose() {
    this._animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if(!this._isInit){
      this._isInit = true;
      this._context = context;
      context = null;
    }
    this._nombreFile = widget.dataTd['td_td'];
    this._nombreFile = this._nombreFile.replaceFirst('.pdf', '.jpg');
    this._lstInFavs = Provider.of<DataShared>(this._context, listen: false).tarjInFav;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey[400],
          width: 1
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(this._context).size.width,
            height: 210,
            child: _imagenTd(),
          ),
          _giro(),
          Divider(
            color: Colors.grey,
            indent: 5,
            endIndent: 5,
          ),
          Padding(
            padding: EdgeInsets.all(3),
            child: _links(),
          )
        ],
      ),
    );
  }

  ///
  Widget _imagenTd() {

    String nombreEmpresa = widget.dataTd['td_nombreEmpresa'].toString();
    nombreEmpresa = (nombreEmpresa.length > 32) ? nombreEmpresa.substring(0, 32) + '...' : nombreEmpresa;

    Widget queImagen = _imgProximamente();

    if(widget.dataTd.containsKey('ds_status')) {
      if(widget.dataTd['ds_status'] == 'terminado' && this._nombreFile != '0') {
        queImagen = _imgCard(this._nombreFile);
      }
    }else{
      if(this._nombreFile != '0') {
        queImagen = _imgCard(this._nombreFile);
      }
    }

    return Stack(
      overflow: Overflow.clip,
      children: [
        InkWell(
          onTap: (){
            this._animationController.repeat(reverse: true);
            setState(() { });
            Future.delayed(Duration(seconds: 2), (){
              this._animationController.stop();
            });
          },
          child: queImagen,
        ),
        Positioned(
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(right: 40),
            width: MediaQuery.of(this._context).size.width,
            height: 30,
            color: Colors.black.withAlpha(150),
            child: Padding(
              padding: EdgeInsets.only(top: 5, right: 10),
              child: Text(
                '$nombreEmpresa',
                textScaleFactor: 1,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'Lemon',
                  fontSize: 18,
                  letterSpacing: 1
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  ///
  Widget _imgProximamente() {

    return _clipImg(
      SizedBox(
        height: 260,
        width: MediaQuery.of(this._context).size.width,
        child: Image(
          image: AssetImage('assets/images/proximamente.jpg'),
          fit: BoxFit.cover,
        ),
      )
    );
  }

  ///
  Widget _imgPlaceHolder() {

    return _clipImg(
      SizedBox(
        height: 260,
        width: MediaQuery.of(this._context).size.width,
        child: Image(
          image: AssetImage('assets/images/nada_pdf_image.jpg'),
          fit: BoxFit.cover,
        ),
      )
    );
  }

  ///
  Widget _imgCard(String nombreFile) {

    return _clipImg(
      SizedBox(
        width: MediaQuery.of(this._context).size.width,
        height: 260,
        child: CachedNetworkImage(
          imageUrl: '${globals.baseThumTds}/$nombreFile',
          fit: BoxFit.cover,
          placeholder: (_, String url){
            return _imgPlaceHolder();
          },
          useOldImageOnUrlChange: true,
          errorWidget: (context, url, error) {
            return _imgPlaceHolder();
          },
        ),
      )
    );
  }

  ///
  Widget _clipImg(Widget hijo) {

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: hijo,
    );
  }

  ///
  Widget _giro() {

    return Padding(
      padding: EdgeInsets.only(top: 5, right: 3, left: 0, bottom: 5),
      child: Text(
        '${widget.dataTd['td_giro']}',
        textScaleFactor: 1,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16
        ),
      ),
    );
  }

  ///
  Widget _links() {

    Map<String, dynamic> resultado = _determinarLinks();
    List<Widget> listLinks = new List();
    if(resultado.containsKey('widgets')){
      listLinks = resultado['widgets'];
    }

    bool terminado = false;
    if(widget.callFrom == 'favs'){
      terminado = true;
    }else{

      if(widget.dataTd.containsKey('ds_status')) {
        if(widget.dataTd['ds_status'] == 'terminado' && this._nombreFile != '0') {
          terminado = true;
        }
      }
    }

    Function accionSalvar = (){};
    this._colorFav = Colors.grey[300];

    if(widget.callFrom != 'favs') {
      // si estamos en la pagina de resultados, el icono de favoritos debe cambiar.
      // a corazon roto rojo en dado caso de que exista y poder eliminar la tarjeta de favoritos.
      int hasFav = this._lstInFavs.firstWhere((element) => (element == widget.dataTd['td_id']), orElse: () => -1);
      if(hasFav != -1){
        this._isInFav = true;
        this._icoFav = FontAwesomeIcons.heartBroken;
        accionSalvar = (!terminado) ? accionSalvar : () async {
          await _eliminarTarjeta();
        };
      }else{
        accionSalvar = (!terminado) ? accionSalvar : () async {
          _toFavoritos().then((accion) async => await _existeInFav(accion));
        };
      }
      
      this._colorFav = (this._isInFav) ? Colors.red : Colors.blue;
    }

    listLinks.add(
      _link(
        icono: this._icoFav, color: this._colorFav, size: 20,
        accion:accionSalvar
      )
    );

    listLinks.add(
      _link(
        icono: FontAwesomeIcons.shareAlt, color: (terminado) ? Colors.orange : Colors.grey[300], size: 20,
        accion: (!terminado) ? (){} : () async {
          Provider.of<DataShared>(this._context, listen: false).setTdNombreFile( _formarLinkFilePdfServer(absolut: false) );
          await sharedFileWidget.shareTd(this._context, 'visor');
        } 
      )
    );

    listLinks.add(
      Expanded(
        flex: 1,
          child: Align(
            alignment: Alignment.centerRight,
            child: _link(
              icono: FontAwesomeIcons.ellipsisV, color: Colors.black, size: 20,
              accion: () =>_verMasLinks((resultado.containsKey('linksUsador')) ? resultado['linksUsador']: new List())
            ),
          ),
        )
    );

    return FadeTransition(
      opacity: this._animationController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(18)
          )
        ),
        child: Row( children: listLinks ),
      ),
    );
  }

  ///
  Map<String, dynamic> _determinarLinks() {

    List<Widget> nuevaLista = new List();
    List<String> linkUsados = new List();

    if(widget.dataTd['td_lstLinks'] != null) {

      List<Map<String, dynamic>> lstLks = new List();
      if(widget.callFrom == 'favs'){
        lstLks = List<Map<String, dynamic>>.from(json.decode(widget.dataTd['td_lstLinks']));
      }else{
        lstLks = List<Map<String, dynamic>>.from(widget.dataTd['td_lstLinks']);
      }
      
      if(lstLks.isEmpty) return new Map();

      // Observamos si tiene link para Llamada.
      Map<String, dynamic> llamada = lstLks.firstWhere((element) => (element['urlCliente'].toString().startsWith('tel://33')), orElse: () => new Map());
      if(llamada.isNotEmpty){
        if(llamada['select']){
          linkUsados.add(llamada['value']);
          nuevaLista.add(
            _link(
              icono: FontAwesomeIcons.phoneVolume, color: Colors.grey[600], size: 20,
              accion: () => _openLink(llamada['urlCliente'])
            )
          );
        }
      }

      // Observamos si tiene link para Whatsapp.
      Map<String, dynamic> whatsapp = lstLks.firstWhere((element) => (element['urlCliente'].toString().startsWith('https://wa.me/5233')), orElse: () => new Map());
      if(whatsapp.isNotEmpty){
        if(whatsapp['select']){
          linkUsados.add(whatsapp['value']);
          nuevaLista.add(
            _link(
              icono: FontAwesomeIcons.whatsapp, color: Colors.green, size: 20,
              accion: () => _openLink(whatsapp['urlCliente'])
            )
          );
        }
      }

      // Observamos si tiene link para Instagram dandole prioridad por las fotos.
      Map<String, dynamic> instagram = lstLks.firstWhere((element) => (element['value'] == 'instagram'), orElse: () => new Map());
      if(instagram.isNotEmpty){
        if(instagram['select']){
          linkUsados.add(instagram['value']);
          nuevaLista.add(
            _link(
              icono: FontAwesomeIcons.instagram, color: Colors.red, size: 20,
              accion: () => _openLink(instagram['urlCliente'])
            )
          );
        }
      }

      if(nuevaLista.length < 3) {
        // Observamos si tiene link para Facebook.
        Map<String, dynamic> facebook = lstLks.firstWhere((element) => (element['value'] == 'facebook'), orElse: () => new Map());
        if(facebook.isNotEmpty){
          if(facebook['select']){
            linkUsados.add(facebook['value']);
            nuevaLista.add(
              _link(
                icono: FontAwesomeIcons.facebook, color: const Color(0xff0070B3), size: 20,
                accion: () => _openLink(facebook['urlCliente'])
              )
            );
          }
        }
      }

      if(nuevaLista.length < 3) {
        nuevaLista.add(const SizedBox(width: 35));
      }
    }

    return {'widgets':nuevaLista, 'linksUsador':linkUsados};
  }

  ///
  Widget _link({IconData icono, Color color, Function accion, double size}) {

    return IconButton(
      icon: FaIcon(icono, color: color, size: size),
      onPressed: accion
    );
  }

  ///
  Future<bool> _toFavoritos() async {

    bool acc = await showDialog(
      context: context,
      barrierDismissible: false,
      useSafeArea: true,
      builder: (_)  => TarjeteroSaveWidget(contextParent: this._context, paraSalvar: widget.dataTd)
    );
    return acc;
  }

  ///
  Future<void> _existeInFav(bool accion) async {

    if(accion){
      setState(() {
        this._icoFav = FontAwesomeIcons.heartBroken;
        this._colorFav = Colors.red;
        this._isInFav = true;
      });
    }
  }

  ///
  Future<void> _openLink(String link) async {

    if (await canLaunch(link)) {
      await launch(link);
    } else {
      setState(() {
        String err = 'No se pudo abrir el navegador, Inténtalo nuevamente, por favor.';
        print(err);
      });
    }
  }

  ///
  Future<void> _verMasLinks(List linksUsados) async {
    
    List<Map<String, dynamic>> nuevaLista = new List();
    List<Map<String, dynamic>> lstLks = new List();

    if(widget.dataTd['td_lstLinks'] != null){
      if(widget.callFrom == 'favs'){
        lstLks = List<Map<String, dynamic>>.from(json.decode(widget.dataTd['td_lstLinks']));
      }else{
        lstLks = List<Map<String, dynamic>>.from(widget.dataTd['td_lstLinks']);
      }

      if(lstLks.length > linksUsados.length) {
        for (var i = 0; i < lstLks.length; i++) {
          Map<String, dynamic> has = lstLks.firstWhere((element) => (!linksUsados.contains(element['value'])), orElse: () => new Map());
          if(has.isNotEmpty){
            Map<String, dynamic> existe = nuevaLista.firstWhere((element) => (element['urlCliente'] == has['urlCliente']), orElse: () => new Map());
            if(existe.isEmpty){
              nuevaLista.add(has);
            }
          }
        }
      }
    }

    bool terminado = false;
    if(widget.callFrom == 'favs'){
      terminado = true;
    }else{
      if(widget.dataTd.containsKey('ds_status')) {
        if(widget.dataTd['ds_status'] == 'terminado' && this._nombreFile != '0') {
          terminado = true;
        }
      }
    }

    showModalBottomSheet(
      context: this._context,
      barrierColor: (!terminado) ? Color(0xffFFFFFF).withAlpha(0) : Color(0xff000000).withAlpha(180),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
        )
      ),
      builder: (_) {
        return (terminado) ? _listaDeAcciones(nuevaLista) : _esperalaMuyPronto();
      }
    );
  }

  ///
  Widget _listaDeAcciones(List<Map<String, dynamic>> nuevaLista) {

    List<Widget> acciones = new List();
    acciones.add(  SizedBox(height: 35) );

    String nombreEmpresa = widget.dataTd['td_nombreEmpresa'].toString();
    nombreEmpresa = (nombreEmpresa.length > 32) ? nombreEmpresa.substring(0, 32) + '...' : nombreEmpresa;

    if(nuevaLista.length > 0) {
      nuevaLista.forEach((element) {
        if(element['select']){
          Map<String, dynamic> elementoLink = _getLinkRs(element['value']);
          acciones.add(  _cardAcciones(elementoLink, element['urlCliente']) );
        }
      });
    }

    acciones.add(  _cardAcciones(_getLinkRs('verPDF'), 'verPDF') );
    if(widget.callFrom == 'favs') {
      acciones.add(  _cardAcciones(_getLinkRs('elimFav'), 'elimFav') );
    }

    double tamanio = (acciones.length <= 3) ? 0.4 : 0.5;
    if(tamanio == 0.5){
      tamanio = (acciones.length > 3) ? 0.6 : tamanio;
    }

    return Container(
      width: MediaQuery.of(this._context).size.width,
      height: MediaQuery.of(this._context).size.height * tamanio,
      decoration: BoxDecoration(
        color: const Color(0xff04142d),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
        )
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)
            ),
            child: Image(
              image: AssetImage('assets/images/bg_socials_media.jpg'),
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.softLight,
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: acciones,
          ),
          Positioned(
            top: 0,
            child: Container(
              width: MediaQuery.of(this._context).size.width,
              height: 40,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff000000).withAlpha(100),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20)
                )
              ),
              child: Text(
                '$nombreEmpresa',
                textScaleFactor: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFFFFFF),
                  fontFamily: 'Lemon',
                  fontSize: 18,
                  letterSpacing: 1
                ),
              ),
            ),
          )
        ],
      )
    );
  }

  ///
  Widget _cardAcciones(Map<String, dynamic> elementoLink, String accion) {

    Function accionFnc;
    
    if(accion == 'verPDF') {
      String nombreDelArchivo = _formarLinkFilePdfServer();
      Provider.of<DataShared>(this._context, listen: false).setTdFromNet(nombreDelArchivo);
      Provider.of<DataShared>(this._context, listen: false).setParaSave(widget.dataTd);
      accionFnc = () => Navigator.of(this._context).pushNamedAndRemoveUntil('visor_td_page', (route) => false);
    }else{

      if(accion == 'elimFav') {
        accionFnc = () async => _eliminarTarjeta();
      }else{
        accionFnc = () async => _openLink(accion);
      }
    }

    return InkWell(
      onTap: accionFnc,
      child: Container(
        width: MediaQuery.of(this._context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffFFFFFF),
          borderRadius: BorderRadiusDirectional.circular(10)
        ),
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${elementoLink['titulo']}',
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xff0070B3)
                    ),
                  ),
                  Divider(),
                  Text(
                    '${elementoLink['value'].toString().toUpperCase()}',
                    textScaleFactor: 1,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lemon',
                      fontSize: 18,
                      letterSpacing: 1,
                      color: Colors.grey
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: elementoLink['icono'],
            ),
          ],
        ),
      ),
    );
  }
  
  ///
  Widget _esperalaMuyPronto() {

    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: MediaQuery.of(this._context).size.height * 0.08,
      width: MediaQuery.of(this._context).size.width,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20)
        )
      ),
      child: const Text(
        '¡Esperala muy Pronto!',
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xffFFFFFF),
          fontSize: 18,
          fontFamily: 'Lemon',
          letterSpacing: 1.5
        ),
      ),
    );
  }

  ///
  Map<String, dynamic> _getLinkRs(String link) {

    double tamanio = 40;
    Color color = const Color(0xff0070B3);

    Map<String, dynamic> rs = 
    {
      'whatsapp': {
        'value' :'whatsapp',
        'titulo':'Envianos un Mensaje',
        'icono' : FaIcon(FontAwesomeIcons.whatsapp, color: color, size: tamanio),
      },
      'facebook': {
        'value' : 'facebook',
        'titulo': 'Siguenos en Facebook',
        'icono' : FaIcon(FontAwesomeIcons.facebook, color: color, size: tamanio),
      },
      'instagram': {
        'value' : 'instagram',
        'titulo': 'Conoce mis Catalogo en Instagram',
        'icono' : FaIcon(FontAwesomeIcons.instagram, color: color, size: tamanio),
      },
      'youtube': {
        'value' : 'youtube',
        'titulo': 'Revisa mis videos en Youtube',
        'icono' : FaIcon(FontAwesomeIcons.youtube, color: color, size: tamanio),
      },
      'linkedin': {
        'value' : 'linkedin',
        'titulo': 'Conoceme más en Linkedin',
        'icono' : FaIcon(FontAwesomeIcons.linkedin, color: color, size: tamanio),
      },
      'twitter': {
        'value' : 'twitter',
        'titulo': 'Enterate de todo en Twitter',
        'icono' : FaIcon(FontAwesomeIcons.twitter, color: color, size: tamanio),
      },
      'tiktok': {
        'value' : 'tiktok',
        'titulo': 'Siguenos en TikTok',
        'icono' : FaIcon(FontAwesomeIcons.tiktok, color: color, size: tamanio),
      },
      'google_maps': {
        'value' : 'MAPA',
        'titulo': 'Ubicanos en...',
        'icono' : FaIcon(FontAwesomeIcons.mapMarkedAlt, color: color, size: tamanio),
      },
      'otros': {
        'value' : 'otros',
        'titulo': 'Revisa mis Otros Enlaces',
        'icono' : FaIcon(FontAwesomeIcons.link, color: color, size: tamanio),
      },
      'verPDF': {
        'value' : 'ver t.d.',
        'titulo': 'Ver Tarjeta Digital',
        'icono' : FaIcon(FontAwesomeIcons.fileAlt, color: color, size: tamanio),
      },
      'elimFav': {
        'value' : 'ELIMINAR',
        'titulo': 'Quitar Tarjeta de Favoritos',
        'icono' : FaIcon(FontAwesomeIcons.trashAlt, color: color, size: tamanio),
      },
    };

    if(!rs.containsKey(link)){
      link = 'otros';
    }

    return rs[link];
  }

  ///
  String _formarLinkFilePdfServer({bool absolut: true}) {

    String nombreDelArchivo = this._nombreFile;
    if(nombreDelArchivo.endsWith('.jpg')) {
        nombreDelArchivo = nombreDelArchivo.replaceFirst('.jpg', '.pdf');
    }
    return (absolut) ? '${globals.baseTds}/$nombreDelArchivo' : nombreDelArchivo;
  }

  ///
  Future<void> _eliminarTarjeta() async {

    bool acc = await alertsVarios.showMsgAceptarCancel(
      context: this._context,
      titulo: 'ELIMINAR TARJETA',
      body: '¿Estas segur@ de querer quitar permanentemente de tus favoritos la tarjeta seleccionada?'
    );
    if(acc){
      if(widget.callFrom == 'favs'){
        Navigator.of(this._context).pop(false);
      }
      bool echo = await emTds.deleteTarjetaBy(key: 'td_td', valor: widget.dataTd['td_td']);
      if(echo) {
        Provider.of<DataShared>(this._context, listen: false).setTarjInFav(widget.dataTd['td_id'], elim: true);
        this._icoFav = FontAwesomeIcons.heart;
        this._colorFav = Colors.blue;
        this._isInFav = false;
        setState(() { });
      }
    }
  }


}