import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totalizer_cart/tela_principal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]).then((_){
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: TelaPrincipal(),
    );
  }
}