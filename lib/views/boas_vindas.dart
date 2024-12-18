import 'package:flutter/material.dart';
import 'package:totalizer_cart/views/importar.dart';
import 'package:totalizer_cart/views/tela_principal.dart';

class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Adicionando a imagem aqui
            CircleAvatar(
              radius: 80, // Tamanho da imagem
              backgroundImage:
                  AssetImage('assets/icon/icon1.png'), // Caminho para a imagem
              backgroundColor: Colors.transparent,
            ),
            const Text(
              'TOTALIZER',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Seja bem vindo!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // inicia sem importar uma lista
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TelaPrincipal()),
                    );
                  },
                  child: const Text(
                    'Iniciar sem lista',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // importa uma lista do app de celular
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ImportScreen()),
                    );
                  },
                  child: const Text(
                    'Importar lista',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
