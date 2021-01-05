import 'package:flutter/material.dart';

class AlertsVarios {

  BuildContext _context;

  /// Utilizado para mostrar un dialogo en proceso
  Widget procesandoFlat({
    String body
  }) {

    List<Widget> contenido = _contentDeProcesando(body);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: contenido.toList(),
    );
  }

  ///
  List<Widget> _contentDeProcesando(String body) {

    return [
      const SizedBox(height: 10),
      LinearProgressIndicator(),
      Image(
        image: AssetImage('assets/images/send_data.jpg'),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          body,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey
          ),
        ),
      )
    ];
  }

  /// Utilizado para mostrar un dialogo en proceso
  Future<void> procesando({
    BuildContext context,
    String titulo,
    String body
  }) async {

    this._context = context;
    context = null;

    List<Widget> contenido = _contentDeProcesando(body);

    _dialog(
      _alertDialogo(
        childContenido: contenido.toList(),
        titulo: titulo
      )
    );
  }

  /// Utilizado para mostrar un dialogo en proceso
  Future<void> showMsgError({
    BuildContext context,
    String titulo,
    String body
  }) async {

    this._context = context;
    context = null;

    List<Widget> contenido = [
      const SizedBox(height: 10),
      Image(
        image: AssetImage('assets/images/error_data.jpg'),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          body,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red
          ),
        ),
      ),
      const SizedBox(height: 7),
      FlatButton(
        onPressed: () => Navigator.of(this._context).pop(false),
        child: Text(
          'ENTENDIDO',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xff0070B3),
            fontWeight: FontWeight.bold
          )
        )
      )
    ];

    _dialog(
      _alertDialogo(
        childContenido: contenido.toList(),
        titulo: titulo
      )
    );
  }

  /// Utilizado para mostrar un dialogo en proceso
  Future<bool> showMsgAceptarCancel({
    BuildContext context,
    String titulo,
    String body
  }) async {

    this._context = context;
    context = null;

    List<Widget> contenido = [
      const SizedBox(height: 10),
      Image(
        image: AssetImage('assets/images/error_data.jpg'),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: Text(
          body,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red
          ),
        ),
      ),
      const SizedBox(height: 7),
      _btnAccionRounded(
        icono: Icons.delete,
        titulo: 'ACEPTAR',
        fnc: () => Navigator.of(this._context).pop(true),
        bg: Colors.red
      ),
      const SizedBox(height: 10),
      _btnAccionRounded(
        icono: Icons.close,
        titulo: 'CANCELAR',
        fnc: () => Navigator.of(this._context).pop(false),
        bg: Colors.orange
      ),
      const SizedBox(height: 10),
    ];

    return showDialog(
      barrierDismissible: false,
      context: this._context,
      builder: (_) {
        return _alertDialogo(
          childContenido: contenido.toList(),
          titulo: titulo
        );
      }
    );
  }

  ///
  Widget _btnAccionRounded({
    String titulo,
    Color bg,
    IconData icono,
    Function fnc
  }) {

    return SizedBox(
      width: MediaQuery.of(this._context).size.width * 0.5,
      child: RaisedButton.icon(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)
        ),
        icon: Icon(icono, color: Colors.white),
        onPressed: () => fnc(),
        color: bg,
        label: Text(
          '$titulo',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xffFFFFFF),
            fontWeight: FontWeight.bold
          )
        )
      )
    );
  }

  ///
  Widget _alertDialogo({List<Widget> childContenido, String titulo}) {

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      contentPadding: EdgeInsets.all(0),
      title: Text(
        titulo,
        textScaleFactor: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xffCEB800)
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: childContenido,
      ),
    );
  }

  ///
  Future<void> _dialog(Widget alerta) async {

    showDialog(
      barrierDismissible: false,
      context: this._context,
      builder: (_) {
        return alerta;
      }
    );
  }
}