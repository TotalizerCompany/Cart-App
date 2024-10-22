import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:archive/archive.dart';
class TelaQrCode extends StatelessWidget{
  final List<dynamic> minhalista;

  const TelaQrCode({super.key, required this.minhalista});
  //Função para compactar a lista em gZip
  Future <String> compactarLista(List<dynamic> lista) async{
    //converte a lista em string (formato JSON)
    String dadosString = jsonEncode(lista);
    //converte a string em bytes (formato UTF-8)
    List<int> dadosBytes = utf8.encode(dadosString);
    //compacta os os bytes com o GZip
    List<int> comprimido = GZipEncoder().encode(dadosBytes)!;

    return base64Encode(comprimido);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.orange[400],
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white
          ),
          child: FutureBuilder<String>(
            future: compactarLista(minhalista), 
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const CircularProgressIndicator();
              }else if(snapshot.hasError){
                return Text('Erro ao compactar: ${snapshot.error}');
              }else{
                String conteudoCompactado = snapshot.data!;
                return QrImageView(
                  data: conteudoCompactado,
                  version: QrVersions.auto,
                  size: 180.0,
                );
              }
            }
          )
        ),
      )
    );
  }
}