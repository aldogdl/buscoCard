import 'package:flutter/material.dart';

import 'src/templates/Init_config_page.dart';
import 'src/templates/base_index.dart';
import 'src/templates/login_page.dart';
import 'src/templates/change_pass_page.dart';
import 'src/templates/index_page.dart';
import 'src/templates/login_succes_page.dart';
import 'src/templates/visor_td_page.dart';
import 'src/templates/visor_url_qr_page.dart';
import 'src/templates/tarjetero_page.dart';
import 'src/templates/result_busqueda.dart';
import 'src/templates/asesor_get_data.dart';

class Rutas {

  Map<String, Widget Function(BuildContext)> getRutas(BuildContext context) {

    return {
      'init_config_page'             : (context) => InitConfigPage(),
      'base_index_page'              : (context) => BaseIndex(),
      'login_page'                   : (context) => LoginPage(),
      'login_succes_page'            : (context) => LoginSuccesPage(),
      'change_pass_page'             : (context) => ChangePassPage(),
      'index_page'                   : (context) => IndexPage(),
      'visor_td_page'                : (context) => VisorTdPage(),
      'visor_url_qr_page'            : (context) => VisorUrlQrPage(),
      'tarjetero_page'               : (context) => TarjeteroPage(),
      'result_busqueda_page'         : (context) => ResultBusquedaPage(),
      'asesor_get_data'              : (context) => AsesorGetData(),
    };
  }
}