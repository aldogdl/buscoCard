import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../repository/user_repository.dart';
import '../data_shared.dart';
import '../utils/text_utils.dart';
import 'widgets/alerts_varios.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  UserRepository emUser = UserRepository();
  AlertsVarios alertsVarios = AlertsVarios();
  TextUtils textUtils = TextUtils();

  TextEditingController _username = TextEditingController();
  TextEditingController _password = TextEditingController();
  FocusNode _usernameFocus        = FocusNode();
  FocusNode _passwordFocus        = FocusNode();
  GlobalKey<FormState> _frmKey    = GlobalKey<FormState>();

  bool _isInit = false;
  bool _verPass = true;
  IconData _iconoVerPass = Icons.remove_red_eye;
  BuildContext _context;
  Size _screen;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  void dispose() {
    this._username?.dispose();
    this._password?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._context = context;
      context = null;
      WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    }

    this._screen = MediaQuery.of(this._context).size;

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          Provider.of<DataShared>(this._context, listen: false).setIndexTap(1);
          Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
          return Future.value(true);
        },
        child: _body(),
      ),
    );
  }

  ///
  Widget _body() {

    return Container(
      padding: EdgeInsets.all(this._screen.width * 0.07),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xff0070B3),
            const Color(0xff00FFFF),
            const Color(0xffCEB800),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter
        )
      ),
      child: Center(
        child: Form(
          key: this._frmKey,
          child: ListView(
            children: [
              Container(
                margin: EdgeInsets.only(top: this._screen.height * 0.03),
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: const Color(0xffFFFFFF),
                ),
                child: Text(
                  '¡BIENVENIDO!',
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: this._screen.width * 0.09,
                    color: const Color(0xff0070B3),
                    fontFamily: 'Lemon'
                  ),
                ),
              ),
              SizedBox(height: this._screen.width * 0.09),
              // contenedor de Inputs
              Container(
                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xffFFFFFF),
                    width: 2
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Column(
                  children: [
                    _titulares('USUARIO:'),
                    const SizedBox(height: 10),
                    _contenedorDeInput(_fieldUsername()),
                    const SizedBox(height: 30),
                    _titulares('CONSTRASEÑA:'),
                    const SizedBox(height: 10),
                    _contenedorDeInput(_fieldPassword()),
                    const SizedBox(height: 20),
                    _contenedorDeLabels(
                      SizedBox(
                        width: this._screen.width,
                        child: FlatButton(
                          onPressed: () async {
                            if(this._frmKey.currentState.validate()){
                              await _sendData();
                            }
                          },
                          padding: EdgeInsets.all(0),
                          height: 0,
                          visualDensity: VisualDensity.compact,
                          child: Text(
                            'INICIAR',
                            textScaleFactor: 1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xff0070B3),
                              fontSize: 17
                            ),
                          ),
                        ),
                      )
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FlatButton(
                onPressed: (){
                  
                },
                child: Text(
                  '¿Olvidaste tu Contraseña?',
                  textScaleFactor: 1,
                  textAlign: TextAlign.center,
                )
              )
            ],
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _initWidget(_) async {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Color(0xff0070B3).withAlpha(100),
      systemNavigationBarColor: Color(0xffCEB800),
      systemNavigationBarIconBrightness: Brightness.dark
    ));
    setState(() { });
  }

  ///
  Widget _contenedorDeInput(Widget input) {

    return Container(
      padding: EdgeInsets.only(top: 0, right: 10, bottom: 20, left: 10),
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(20)
      ),
      child: input,
    );
  }

  ///
  Widget _contenedorDeLabels(Widget input) {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xffFFFFFF),
        borderRadius: BorderRadius.circular(20)
      ),
      child: input,
    );
  }

  /// Las etiquetas de los inputs
  Widget _titulares(String label) {

    return _contenedorDeLabels(
      Container(
        width: this._screen.width * 0.50,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        child: Text(
          '$label',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xff0070B3),
            fontSize: 17,
            fontFamily: 'Lemon'
          ),
        ),
      )
    );
  }

  /// Campo para el username
  Widget _fieldUsername() {

    return TextFormField(
      controller: this._username,
      focusNode: this._usernameFocus,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (String _) {
        FocusScope.of(this._context).requestFocus(this._passwordFocus);
      },
      decoration: InputDecoration(
      ),
      validator: (String txt){
        if(txt.isEmpty){
          return 'El Usuario es Requerido';
        }
        return null;
      },
    );
  }

  /// Campo para el password
  Widget _fieldPassword() {

    return TextFormField(
      controller: this._password,
      focusNode: this._passwordFocus,
      obscureText: this._verPass,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (String _) async {
        String body = 'Estamos comprobando credenciales, por favor, espera un momento';
        if(this._frmKey.currentState.validate()){
          alertsVarios.procesando(context: this._context, titulo: 'AUTENTICANDO', body: body);
          await _sendData();
        }
      },
      decoration: InputDecoration(
        suffixIcon: InkWell(
          child: Icon(this._iconoVerPass, color: const Color(0xff6591aa)),
          onTap: (){
            if(this._verPass) {
              setState(() {
                this._verPass = false;
                this._iconoVerPass = Icons.no_encryption;
              });
            }else{
              setState(() {
                this._verPass = true;
                this._iconoVerPass = Icons.remove_red_eye;
              });
            }
          },
        )
      ),
      validator: (String txt){
        if(txt.isEmpty){
          return 'La Contraseña es Requerida';
        }
        return null;
      },
    );
  }

  ///
  Future<void> _sendData() async {

    FocusScope.of(this._context).requestFocus(new FocusNode());
    String body = 'Estamos comprobando credenciales, por favor, espera un momento';
    alertsVarios.procesando(context: this._context, titulo: 'AUTENTICANDO', body: body);

    Map<String, dynamic> dataUser = {
      '_usname' : textUtils.quitarAcentos(this._username.text, ''),
      '_uspass' : this._password.text
    };
    String token = await emUser.getTokenByUser(dataUser);
    if(token == 'err') {
      Navigator.of(this._context).pop();
      await alertsVarios.showMsgError(context: this._context, titulo: emUser.result['msg'], body: emUser.result['body']);
    }else{

      if(token.length > 50) {
        await _getDataUserFromServer(token);
      }
    }
  }

  /// Recuperamos los datos del usuario para ser almacenados en la BD local
  Future<void> _getDataUserFromServer(String token) async {

    Map<String, dynamic> dataUser = await emUser.getDataUserFromServer(this._username.text, token);
    if(dataUser.isEmpty) {
      Navigator.of(this._context).pop();
      await alertsVarios.showMsgError(context: this._context, titulo: emUser.result['msg'], body: emUser.result['body']);
      return;
    }else{
      dataUser['u_password'] = this._password.text;
      bool insertado = await emUser.setDataUserFromServerInDBLocal(dataUser);
      if(!insertado) {
        Navigator.of(this._context).pop();
        await alertsVarios.showMsgError(context: this._context, titulo: emUser.result['msg'], body: emUser.result['body']);
      }else{
        Provider.of<DataShared>(this._context, listen: false).setTokenServer(token);
        Provider.of<DataShared>(this._context, listen: false).setUsername(this._username.text.toUpperCase());
        Navigator.of(this._context).pushNamedAndRemoveUntil('login_succes_page', (route) => false);
      }
    }
  }

}