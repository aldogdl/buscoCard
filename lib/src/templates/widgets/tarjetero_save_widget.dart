import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_shared.dart';
import '../../utils/text_utils.dart';
import '../../repository/tds_repository.dart';

class TarjeteroSaveWidget extends StatefulWidget {

  final Map<String, dynamic> paraSalvar;
  final BuildContext contextParent;
  TarjeteroSaveWidget({this.contextParent, this.paraSalvar});

  @override
  _TarjeteroSaveWidgetState createState() => _TarjeteroSaveWidgetState();
}

class _TarjeteroSaveWidgetState extends State<TarjeteroSaveWidget> {

  TextUtils textUtils = TextUtils();
  TdsRepository emTds = TdsRepository();

  String _palClas = '0';
  
  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      ),
      insetPadding: EdgeInsets.all(20),
      actions: [
        FlatButton(
          onPressed: () => Navigator.of(widget.contextParent).pop(false),
          child: Text(
            'CANCELAR',
            textScaleFactor: 1,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red
            ),
          )
        ),
        const SizedBox(width: 10),
        _createBtnSave()
      ],
      title: (this._palClas == '0')  ? _showBuscandoPalClasTitle() : _showPalClasTitle(),
      content: (this._palClas == '0') ? _showBuscandoPalClas() : _showPalClas()
    );
  }

  ///
  Widget _showBuscandoPalClasTitle() {

    return Column(
      children: [
        Image(
          image: AssetImage('assets/images/send_data.jpg'),
        ),
        const SizedBox(height: 10),
        Text(
            'PROCESANDO',
            textScaleFactor: 1,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xff0070B3),
              fontFamily: 'Lemon',
              fontSize: 18,
              letterSpacing: 5
            )
          )
      ],
    );
  }

  ///
  Widget _showPalClasTitle() {

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: Icon(Icons.star, size: 40, color: Colors.amber),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Guardar en mi TARJETERO',
            textScaleFactor: 1,
            textAlign: TextAlign.left,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xff0070B3),
              fontFamily: 'Lemon',
              fontSize: 16,
              letterSpacing: 5
            )
          ),
        )
      ],
    );
  }

  ///
  Widget _showBuscandoPalClas() {

    return Column(
      children: [
        Text(
          'Espera un momento por favor, estamos buscando las palabras con las que podrás '
          'relacionar y buscar posteriormente a este comercio.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey
          ),
        ),
      ],
    );
  }

  ///
  Widget _showPalClas() {

    List<String> palabras = this._palClas.split(',');

    return Column(
      children: [
        Text(
          'A continuación te mostramos las palabras que podrás utilizar posteriormente '+
          'para encotrar dentro de tus FAVORITOS a este comercio.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            height: 1.5
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '${palabras.join(", ")}',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.blue
          ),
        ),
      ],
    );
  }

  ///
  Widget _createBtnSave() {

    return FutureBuilder(
      future: _buscandoPalClas(),
      builder: (_, AsyncSnapshot snapshot) {

        if(snapshot.connectionState == ConnectionState.done) {
          if(this._palClas != '0') {

            widget.paraSalvar['td_palclas'] = this._palClas;

            return RaisedButton(
              padding: EdgeInsets.symmetric(horizontal: 10),
              onPressed: () async {
                await _makeSave();
              },
              color: const Color(0xff0070B3),
              textColor: const Color(0xffFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text(
                'GUARDAR',
                textScaleFactor: 1,
                style: TextStyle(
                  letterSpacing: 2
                )
              ),
            );
          }
        }
        return RaisedButton(
          padding: EdgeInsets.symmetric(horizontal: 10),
          onPressed: null,
          color: const Color(0xff0070B3),
          textColor: const Color(0xffFFFFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          child: SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  ///
  Future<void> _buscandoPalClas() async {

    if(this._palClas != '0'){ return false; }
    this._palClas = await emTds.getPalClasByIdTd(widget.paraSalvar['td_id']);
    if(this._palClas != '0') {
      setState(() { });
    }
  }

  ///
  Future<bool> _makeSave() async {

    int save = await emTds.setTarjetaInBDLocal(widget.paraSalvar);
    if(save != -1) {
      DataShared dataShared = Provider.of<DataShared>(widget.contextParent, listen: false);
      dataShared.setTarjInFav(widget.paraSalvar['td_id']);
      dataShared.setIndexTap(0);
      Navigator.of(widget.contextParent).pop(true);
      return false;
    }

    return true;
  }

}