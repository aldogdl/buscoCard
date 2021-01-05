import 'package:buscoCard/src/data_shared.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InputBuscador extends StatelessWidget {

  InputBuscador({Key key}) : super(key: key);
  final TextEditingController _buscaCtrl = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: this._buscaCtrl,
      keyboardType: TextInputType.text,
      textAlignVertical: TextAlignVertical.center,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(0),
        hintText: 'Qué estas Buscando...',
        hintStyle: TextStyle(
          fontSize: 13
        ),
        isDense: true
      ),
      onFieldSubmitted: (String txt) => _buscar(context),
      onEditingComplete: () => _buscar(context),
    );
  }

  ///
  Future<void> _buscar(BuildContext context) async {

    Provider.of<DataShared>(context, listen: false).setCriterioBusqueda(this._buscaCtrl.text);
    Navigator.of(context).pushNamedAndRemoveUntil('result_busqueda_page', (route) => false);
    return;
  }
}