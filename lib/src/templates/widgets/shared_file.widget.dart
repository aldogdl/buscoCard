import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../repository/user_repository.dart';
import '../../data_shared.dart';
import 'alerts_varios.dart';

class SharedFileWidget {

  UserRepository emUser = UserRepository();
  AlertsVarios alertsVarios = AlertsVarios();
  
  ///
  Future<void> shareTd(BuildContext context, String from) async {

    String nombreFile = Provider.of<DataShared>(context, listen: false).tdNombreFile;
    if(nombreFile.endsWith('.pdf')) {

      Uint8List bytes;
      try {
        if(from == 'visor'){
          String body = 'Indentificando la Tarjeta Digital para compartir';
          alertsVarios.procesando(context: context, titulo: 'Buscando...', body: body);
          bytes = await emUser.downloadPdfByNombreFile(nombreFile);
          Navigator.of(context).pop();
        }else{
          bytes = await _localFile(context, nombreFile);
        }
      } catch (e) {
        await alertsVarios.showMsgError(context: context, titulo: 'ERROR AL COMPARTIR', body: '!Error: $e');
        return;
      }

      await Share.file('TARJETA DIGITAL', nombreFile, bytes, 'application/pdf');
    }else{
      await alertsVarios.showMsgError(context: context, titulo: 'ERROR AL COMPARTIR', body: '!Error: No se detectó el nombre del archivo.');
      return;
    }

  }


  /// Localizamos el path de Documentos de la app.
  Future<String> get _localPath async {

    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  ///
  Future<Uint8List> _localFile(BuildContext context, String nombreFile) async {

    String pathDoc = await _localPath;
    Uint8List pdf = await File('$pathDoc/$nombreFile').readAsBytes();
    
    return pdf;
  }  
}