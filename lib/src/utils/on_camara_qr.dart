import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OnCamaraQr {

  /// Hacemos el Escaneo
  Future<String> scan() async {

    try {
      String codeResult;
        codeResult = await FlutterBarcodeScanner.scanBarcode(
            "#0070B3", "Cerrar", true, ScanMode.QR);

      if(!codeResult.contains('buscomex')) {
        if(!codeResult.contains('wa.me')){
          if(codeResult.contains('http')) {
            return 'openhttp@$codeResult';
          }else{
            return 'Código Desconocido';
          }
        }else{
          // Abrir Whatsapp
          if (await canLaunch(codeResult)) {
            await launch(codeResult);
          } else {
            return 'No se pudo Abrir::$codeResult';
          }
          return 'ok';
        }
      }else{

        return 'pdf@$codeResult';
      }

    } on PlatformException catch (e) {

      return 'Error::${e.message}';
    }

  }
}