import 'package:flutter/material.dart';

class TienesUnNegocioWidget extends StatelessWidget {
  
  const TienesUnNegocioWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        RaisedButton(
          onPressed: () async => Navigator.of(context).pushNamedAndRemoveUntil('login_page', (route) => false),
          child: Text(
            'autenticarme',
            textScaleFactor: 1,
            style: TextStyle(
              fontSize: 17,
              fontFamily: 'Lemon',
              letterSpacing: 4
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color(0xff0070B3),
          textColor: const Color(0xffFFFFFF),
          elevation: 0,
        ),
        const SizedBox(height: 20),
        Text(
          '¿Tienes un Negocio?',
          textScaleFactor: 1,
          style: TextStyle(
            fontSize: 21,
            fontFamily: 'Lemon',
            color: const Color(0xff004060)
          )
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Text(
            'Comparte tus Productos y Servicios a la velocidad de un click',
            textScaleFactor: 1,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xff0070B3),
              fontSize: 15
            )
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FlatButton(
            child: Text(
              'CONOCER MÁS',
              textScaleFactor: 1,
              style: TextStyle(
                decoration: TextDecoration.underline
              ),
            ),
            onPressed: (){
              
            },
          ),
        )
      ],
    );
  }
}