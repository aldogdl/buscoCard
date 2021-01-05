import 'package:flutter/material.dart';
import '../../tema_gral.dart' as tema;

class BottomNavigationMy extends StatelessWidget {
  const BottomNavigationMy({Key key}) : super(key: key);
        
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      elevation: 0,
      iconSize: 20,
      type: BottomNavigationBarType.fixed,
      backgroundColor: tema.primaryColor,
      showUnselectedLabels: false,
      showSelectedLabels: false,
      selectedIconTheme: IconThemeData(
        color: tema.textOverPrimary
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.grey[400]
      ),
      items: [
        BottomNavigationBarItem(
          icon: Icon( Icons.home),
          backgroundColor: Colors.yellow,
          label: 'Inicio'
        ),
        BottomNavigationBarItem(
          icon: Icon( Icons.tab_unselected ),
          label: 'Tarjetero'
        ),
        BottomNavigationBarItem(
          icon: Icon( Icons.search ),
          label: 'Buscar'
        ),
        BottomNavigationBarItem(
          icon: Icon( Icons.qr_code ),
          label: 'Leer QR'
        ),
        BottomNavigationBarItem(
          icon: Icon( Icons.qr_code ),
          label: 'Productos'
        ),
      ],
    );
  }
}