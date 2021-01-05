import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repository/user_repository.dart';
import '../../templates/widgets/alerts_varios.dart';
import '../../data_shared.dart';
import '../../globals.dart' as globals;

class MenuDrawer extends StatelessWidget {

  MenuDrawer({Key key}) : super(key: key);
  
  final UserRepository emUser = UserRepository();
  final AlertsVarios alertsVarios = AlertsVarios();

  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: _menuMain(context),
    );
  }

  ///
  Widget _menuMain(BuildContext context) {

    String username = Provider.of<DataShared>(context, listen: false).username;
    if(username == null) {
      username = 'Aplicación Android:';
    }else{
      username = '$username:';
    }

    return SafeArea(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              height: 70,
              child: Image(
                image: AssetImage('assets/images/logo_bcard.jpg'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Tu Tarjetero y Buscador de Comercios Electrónico',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lemon',
                fontSize: 15,
                color: Colors.grey
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(10),
            color: Colors.grey[300],
            child: Text(
              '$username Version ${globals.version}',
              textScaleFactor: 1,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600]
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            color: Colors.blue.withAlpha(60),
            height: MediaQuery.of(context).size.height * 0.48,
            child: _links(context),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15),
            child: Text(
              'Un producto más de:',
              textScaleFactor: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Lemon',
                fontSize: 12,
                color: Colors.grey
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: SizedBox(
              height: 30,
              child: Image(
                image: AssetImage('assets/images/buscomex_logo.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget _links(BuildContext context) {

    return ListView(
      children: [
        ListTile(
          dense: true,
          leading: Icon(Icons.settings_backup_restore),
          title: Text(
            'Cambiar contraseña',
            textScaleFactor: 1,
          ),
          subtitle: Text(
            'Renueva tu Seguridad'
          ),
          onTap: () async {
            String username = Provider.of<DataShared>(context, listen: false).username;
            if(username == 'Anónimo') {
              String body = 'Para cambiar tus credenciales, es necesario que te Identifques '+
              'primeramente, para ello, preciona el botón de "AUTENTICARME" en la página de Mi Tarjeta';

              await alertsVarios.showMsgError(context: context, titulo: 'ALERTA USUARIO', body: body);

            }else{
              Navigator.of(context).pushNamedAndRemoveUntil('change_pass_page', (route) => false);
            }
          },
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.perm_contact_cal),
          title: Text(
            'Mi Asesor',
            textScaleFactor: 1,
          ),
          subtitle: Text(
            'Contacta a tu Asesor'
          ),
          onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('asesor_get_data', (route) => false),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.help),
          title: Text(
            'Tutoriales y Más',
            textScaleFactor: 1,
          ),
          subtitle: Text(
            'Próximamente'
          ),
        ),
      ],
    );
  }
}