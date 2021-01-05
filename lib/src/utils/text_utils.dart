class TextUtils {

  /*
   * Eliminamos los acentos de las palabras
   * @see AltaSistemaPalClasPage::_inputPalClas
   * @see TdsRepository::_inputPalClas
  */
  String quitarAcentos(String txt, String separador) {
    
    String result;

    List<String> newString = new List();
    Map<String, String> txtSinAcentos = {'á':'a','é':'e','í':'i','ó':'o','ú':'u'};

    List<String> palabras = txt.split(' ');
    palabras.forEach((palabra){
      RegExp exp = RegExp(r'[áéíóú]');
      palabra = palabra.replaceAllMapped(exp, (m){
        return txtSinAcentos[m.group(0)];
      });
      newString.add(palabra.trim().toLowerCase());
    });

    if(newString.length > 0){
      result = newString.join(separador);
    }

    return result;
  }

/*
   * Eliminamos los acentos de las palabras
   * @see AltaSistemaPalClasPage::_inputPalClas
   * @see TdsRepository::_inputPalClas
  */
  String crearCriterioDeBusqueda(String txt) {
    
    String result;

    List<String> newString = new List();
    Map<String, String> txtSinAcentos = {'á':'a','é':'e','í':'i','ó':'o','ú':'u'};
    Map<String, String> articulos = {'el':'','la':'','las':'','los':'','con':'','en':'','de':'','por':''};

    List<String> palabras = txt.split(' ');
    palabras.forEach((palabra){
      RegExp exp = RegExp(r'[áéíóú]');
      palabra = palabra.replaceAllMapped(exp, (m){
        return txtSinAcentos[m.group(0)];
      });
      if(!articulos.containsKey(palabra)) {
        newString.add(palabra.trim().toLowerCase());
      }
    });

    if(newString.length > 0){
      result = newString.join('+');
    }

    return result;
  }

  /*
   * Hacemos slug una palabra o frase
   * @see AltaSistemaPalClasPage::_inputPalClas
  */
  String hacerSlug(String txt, String separadorIni, String separadorFin) {
    
    String result;

    List<String> newString = new List();
    Map<String, String> txtSinAcentos = {'á':'a','é':'e','í':'i','ó':'o','ú':'u'};

    List<String> palabras = txt.split(separadorIni);
    palabras.forEach((palabra){
      RegExp exp = RegExp(r'[áéíóú]');
      palabra = palabra.replaceAllMapped(exp, (m){
        return txtSinAcentos[m.group(0)];
      });
      newString.add(palabra.trim().toLowerCase());
    });

    if(newString.length > 0){
      result = newString.join(separadorFin);
    }

    return result;
  }
}