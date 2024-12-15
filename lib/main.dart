import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totalizer_cart/views/boas_vindas.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Orientação da tela e outras configurçoes visuais do aplicativo
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

    // Inicialização do Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Inicialização da aplicação
    runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TelaBoasVindas(),
    );
  }
}