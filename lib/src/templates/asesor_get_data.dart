import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_shared.dart';
import '../repository/user_repository.dart';
import '../repository/tds_repository.dart';

class AsesorGetData extends StatefulWidget {
  AsesorGetData({Key key}) : super(key: key);

  @override
  _AsesorGetDataState createState() => _AsesorGetDataState();
}

class _AsesorGetDataState extends State<AsesorGetData> {


  UserRepository emUser = UserRepository();
  TdsRepository emTds = TdsRepository();


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        body: Center(
          heightFactor: MediaQuery.of(context).size.height * 0.1,
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
              gradient: LinearGradient(
                colors: [
                  const Color(0xff0070B3).withAlpha(100),
                  const Color(0xffFFFFFF)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter
              )
            ),
            child: FutureBuilder(
              future: _getAsesor(),
              builder: (_, AsyncSnapshot snapshot) {
                if(snapshot.hasData) {
                  return _printDataAsesor(context, snapshot.data);
                }
                return _buscandoData();
                
              },
            ),
          ),
        ),
      ),
    );
  }

  ///
  Future<Map<String, dynamic>> _getAsesor() async {

    Map<String, dynamic> data = await emUser.getDataUserFromDBLocal();
    if(data.isNotEmpty) {
      data = await emTds.getDataAsesor(data['u_id']);
    }else{
      return new Map();
    }

    return data;
  }

  ///
  Widget _buscandoData() {

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image(
          image: AssetImage('assets/images/send_data.jpg')
        ),
        LinearProgressIndicator(),
        const SizedBox(height: 20),
        Text(
          'Espera un Momento por favor, estamos buscando al Asesor que te atendió.',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Lemon',
            fontSize: 18
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  ///
  Widget _printDataAsesor(BuildContext context, Map<String, dynamic> data) {

    print(data);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${data['v_nombre']}',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lemon',
            fontSize: 20
          ),
        ),
        Text(
          '${data['v_movil']}',
          textScaleFactor: 1,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Lemon',
            fontSize: 15
          ),
        ),
        RaisedButton(
          color: Colors.white,
          textColor: Colors.purple,
          onPressed: () {
            Provider.of<DataShared>(context, listen: false).setIndexTap(1);
            Navigator.of(context).pushNamedAndRemoveUntil('base_index_page', (route) => false);
          },
          child: Text(
            'REGRESAR',
            textScaleFactor: 1,
          ),
        )
      ],
    );
  }

}