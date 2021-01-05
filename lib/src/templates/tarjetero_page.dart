import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import '../repository/tds_repository.dart';
import 'widgets/alerts_varios.dart';
import 'widgets/shared_file.widget.dart';
import 'widgets/card_view_widget.dart';
import 'base_index.dart';

class TarjeteroPage extends StatefulWidget {
  TarjeteroPage({Key key}) : super(key: key);

  @override
  _TarjeteroPageState createState() => _TarjeteroPageState();
}

class _TarjeteroPageState extends State<TarjeteroPage> {

  BaseIndex templateBaseGral = BaseIndex();
  SharedFileWidget sharedFileWidget = SharedFileWidget();
  AlertsVarios alertsVarios = AlertsVarios();
  TdsRepository emTds = TdsRepository();

  BuildContext _context;
  List<Map<String, dynamic>> _tarjetas = new List();
  bool _isInit = false;

  @override
  Widget build(BuildContext context) {

    if(!this._isInit){
      this._isInit = true;
      this._context = context;
      context = null;
      Provider.of<DataShared>(this._context, listen: false).setIndexTap(0);
      Provider.of<DataShared>(this._context, listen: false).setIrToPage('base_index_page');
    }

    return _body();
  }

  ///
  Widget _body() {

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      width: MediaQuery.of(this._context).size.width,
      height: MediaQuery.of(this._context).size.height,
      child: Consumer<DataShared>(
        builder: (_, dataShared, __) {
          if(dataShared.tarjInFav.length > 0){
            this._tarjetas = new List();
            return _getFavoritosFromDBLocal();
          }
          return _nadaQueVer('Nada Guardado por el momento');
        },
      )
    );
  }

  ///
  Widget _getFavoritosFromDBLocal() {

    return FutureBuilder(
      future: _getFavoritos(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        if(snapshot.connectionState == ConnectionState.done) {
          if(this._tarjetas.length > 0) {
            return  _listaDeTarjetasInFav();
          }else{
            return _nadaQueVer('Nada Guardado por el momento');
          }
        }

        return Center(
          child: SizedBox(
            height: 40, width: 40,
            child: CircularProgressIndicator()
          ),
        );
      }
    );
  }

  ///
  Widget _listaDeTarjetasInFav() {

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.only(top:20, right: 0, bottom: 0, left: 10),
      itemCount: this._tarjetas.length,
      itemBuilder: (_, int index) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: CardViewWidget(dataTd: this._tarjetas[index], callFrom: 'favs'),
        );
      },
    );
  }

  ///
  Widget _nadaQueVer(String msg) {

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(this._context).size.width * 0.10),
      shrinkWrap: true,
      children: [
        const SizedBox(height: 50),
        Container(
          height: MediaQuery.of(this._context).size.width * 0.7,
          width: MediaQuery.of(this._context).size.width * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xffFFFFFF),
            borderRadius: BorderRadius.circular(200),
            border: Border.all(
              width: 3,
              color: const Color(0xff0070B3).withAlpha(150)
            )
          ),
          child: Icon(Icons.sim_card, size: 150, color: const Color(0xff0070B3).withAlpha(100)),
        ),
        const SizedBox(height: 20),
        Text(
          msg,
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lemon',
            fontSize: 20,
            color: Color(0xff004060)
          ),
        )
      ],
    );
  }

  ///
  Future<void> _getFavoritos() async {

    if(this._tarjetas.isEmpty) {
      this._tarjetas = await emTds.getTarjetaInBDLocal();
    }
  }

}