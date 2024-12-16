import 'package:flutter/material.dart';
import 'package:totalizer_cart/views/importar.dart';
import 'package:totalizer_cart/views/tela_principal.dart';

class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bem-vindo ao TOTALIZER!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // inicia sem importa uma lista
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelaPrincipal()),
                    );
                  },
                  child: const Text('Iniciar sem lista'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    // importa uma lista do app de celular
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ImportScreen()),
                    );
                  },
                  child: const Text('Importar lista'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
