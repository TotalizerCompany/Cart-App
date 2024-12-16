import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:archive/archive.dart';
import 'package:totalizer_cart/views/boas_vindas.dart';

class TelaQrCode extends StatefulWidget {
  final List<dynamic> minhalista;

  const TelaQrCode({super.key, required this.minhalista});

  @override
  _TelaQrCodeState createState() => _TelaQrCodeState();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gerar QR Code"),
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
                    size: 180.0,
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TelaBoasVindas()), // Substitua TelaInicial pela sua tela inicial
                  );
                },
                child: const Text('Voltar para a Tela Inicial'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Função para compactar a lista em gZip
  Future<String> compactarLista(List<dynamic> lista) async {
    //converte a lista em string (formato JSON)
    String dadosString = jsonEncode(lista);
    //converte a string em bytes (formato UTF-8)
    List<int> dadosBytes = utf8.encode(dadosString);
    //compacta os os bytes com o GZip
    List<int> comprimido = GZipEncoder().encode(dadosBytes);
    return base64Encode(comprimido);
  }
}
