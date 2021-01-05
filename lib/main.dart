import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'rutas.dart';
import 'src/data_shared.dart';
import 'src/tema_gral.dart' as tema;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  final Rutas rutas = Rutas();

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DataShared())
      ],
      child: MaterialApp(
        title: tema.nombreApp,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            elevation: 0,
            color: tema.primaryColor,
          )
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('es', 'MX'),
        ],
        initialRoute: 'init_config_page',
        routes: rutas.getRutas(context),
      ),
    );
  }
}
