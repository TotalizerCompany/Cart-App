import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:archive/archive.dart';
import 'package:totalizer_cart/views/boas_vindas.dart';

class TelaQrCode extends StatefulWidget {
  final Map<String, dynamic> minhalista;

  const TelaQrCode({super.key, required this.minhalista});

  @override
  createState() => _TelaQrCodeState();
}

class _TelaQrCodeState extends State<TelaQrCode> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Inicia o timer de 2 minutos
    _startTimer();
  }

  @override
  void dispose() {
    // Cancela o timer ao sair da tela
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Inicia um timer de 2 minutos (120 segundos)
    _timer = Timer(Duration(minutes: 2), () {
      // Quando o timer expirar, retorna à tela inicial
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TelaBoasVindas()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Conteúdo de minhalista: ${widget.minhalista}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTALIZER'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Center(
            child: FutureBuilder<String>(
              future: compactarLista(widget.minhalista),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao compactar: ${snapshot.error}');
                } else {
                  String conteudoCompactado = snapshot.data!;
                  return QrImageView(
                    data: conteudoCompactado,
                    version: QrVersions.auto,
                    size: 170.0,
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                   shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(150, 50),
                backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TelaBoasVindas()),
                  );
                },
                child: const Text('Voltar para a Tela Inicial',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(255, 255, 255, 255),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Função para compactar a lista em gZip
  Future<String> compactarLista(Map<String, dynamic> mapa) async {
    //converte a lista em string (formato JSON)
    String dadosString = jsonEncode(mapa);
    //converte a string em bytes (formato UTF-8)
    List<int> dadosBytes = utf8.encode(dadosString);
    //compacta os os bytes com o GZip
    List<int> comprimido = GZipEncoder().encode(dadosBytes);
    return base64Encode(comprimido);
  }
}
