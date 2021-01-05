import 'package:flutter/material.dart';

class DataShared with ChangeNotifier {

  String _username = 'Anónimo';
  String get username => this._username;
  void setUsername(String username) => this._username = username;
  
  String _tokenServer;
  String get tokenServer => this._tokenServer;
  void setTokenServer(String tokenServer) => this._tokenServer = tokenServer;

  String _tdFromNet;
  String get tdFromNet => this._tdFromNet;
  void setTdFromNet(String tdFromNet) => this._tdFromNet = tdFromNet;

  String _tdNombreFile;
  String get tdNombreFile => this._tdNombreFile;
  void setTdNombreFile(String tdNombreFile) => this._tdNombreFile = tdNombreFile;

  String _irToPage;
  String get irToPage => this._irToPage;
  void setIrToPage(String irToPage) => this._irToPage = irToPage;

  Map<String, dynamic> _paraSave = new Map();
  void setParaSave(Map<String, dynamic> paraSave) => this._paraSave = paraSave;
  Map<String, dynamic> get paraSave => this._paraSave;

  int _indexTap = 1;
  void setIndexTap(int indexTap) => this._indexTap = indexTap;
  int get indexTap => this._indexTap;

  String _criterioBusqueda;
  void setCriterioBusqueda(String criterioBusqueda) => this._criterioBusqueda = criterioBusqueda;
  String get criterioBusqueda => this._criterioBusqueda;

  List<int> _tarjInFav = new List();
  void setTarjInFav(int idTarjeta, {bool elim = false}){
    if(idTarjeta == 0) {
      this._tarjInFav = new List();
    }else{
      if(elim && idTarjeta > 0){
        if(this._tarjInFav.isNotEmpty){
          this._tarjInFav.remove(idTarjeta);
        }
      }else{
        int has = this._tarjInFav.firstWhere((element) => (element == idTarjeta), orElse: () => -1);
        if(has == -1){
          this._tarjInFav.add(idTarjeta);
        }
      }
    }
    
    notifyListeners();
  }

  List<int> get tarjInFav => this._tarjInFav;  
}