import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../repository/user_repository.dart';
import '../repository/tds_repository.dart';
import '../data_shared.dart';
import '../tema_gral.dart' as tema;

class InitConfigPage extends StatefulWidget {
  InitConfigPage({Key key}) : super(key: key);

  @override
  _InitConfigPageState createState() => _InitConfigPageState();
}

class _InitConfigPageState extends State<InitConfigPage> {

  UserRepository emUser = UserRepository();
  TdsRepository emTds = TdsRepository();

  bool _isInit = false;
  String _haciendo = 'Bienvenido';
  BuildContext _context;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_initWidget);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._isInit = true;
      this._context = context;
      context = null;
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
       statusBarColor: tema.splashStatusTopBarrSystem,
       systemNavigationBarColor: tema.splashBarrBottomColor,
       systemNavigationBarIconBrightness: tema.splashBarIconColor
    ));

    LinearGradient backgroundGradient = (tema.splashIntroColor == 'gradient') ? tema.splashGradient : null;
    Color backgroundSolid = (tema.splashIntroColor != 'gradient') ? tema.splashSolid : null;

    return Scaffold(
      body: Container(
        width: MediaQuery.of(this._context).size.width,
        height: MediaQuery.of(this._context).size.height,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: backgroundGradient,
          color: backgroundSolid
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xffFFFFFF),
                  border: Border.all(
                    color: const Color(0xff0070B3)
                  ),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Image(
                  image: AssetImage('assets/images/app_logo.png')
                )
              ),
              const SizedBox(height: 20),
              Text(
                this._haciendo,
                textScaleFactor: 1,
              )
            ],
          ),
        ),
      ),
    );
  }

  /// Iniciando el widget
  Future<void> _initWidget(_) async {
    await _revisandoCredenciales();
    await _getCantTarjetasSalvadas();
  }

  /// Revisamos si existen credenciales ya guardadas en la DB.
  Future<void> _revisandoCredenciales() async {

    setState(() {
      this._haciendo = 'Revisando Credenciales';
    });
    Map<String, dynamic> user = await emUser.getDataUserForGetToken();
    if(user.isNotEmpty) {
      Provider.of<DataShared>(this._context, listen: false).setUsername(user['_usname']);
    }
  }

  /// Revisamos si existen credenciales ya guardadas en la DB.
  Future<void> _getCantTarjetasSalvadas() async {

    setState(() {
      this._haciendo = 'Construyendo Aplicación';
    });
    List tds = await emTds.getTarjetaInBDLocal();
    DataShared dataShared = Provider.of<DataShared>(this._context, listen: false);

    if(tds.isNotEmpty) {
      tds.forEach((element) {
        dataShared.setTarjInFav(element['td_id']);
      });
    }else{
      dataShared.setTarjInFav(0);
    }
    Navigator.of(this._context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
  }
}