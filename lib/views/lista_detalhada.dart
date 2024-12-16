import 'package:flutter/material.dart';
import 'package:totalizer_cart/views/tela_principal.dart'; 

class ListaDetalhadaScreen extends StatelessWidget {
  final String listaId;
  final Map<String, dynamic> listaData;

  const ListaDetalhadaScreen({
    super.key,
    required this.listaId,
    required this.listaData,
  });

  @override
  Widget build(BuildContext context) {
    var itensList = listaData['itens'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes da Lista: $listaId'),
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      body: itensList.isEmpty
          ? Center(child: Text('Nenhum item nesta lista'))
          : ListView.builder(
              itemCount: itensList.length,
              itemBuilder: (context, index) {
                var item = itensList[index];
                var itemNome = item['nome'] ?? 'Sem nome';
                var itemQuantidade = item['quantidade'] ?? 'Indefinido';

                return ListTile(
                  title: Text(itemNome),
                  subtitle: Text('Quantidade: $itemQuantidade'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        onPressed: () {
          // Chama a TelaPrincipal e passa a lista de itens
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaPrincipal(
                listaImportada: List<Map<String, dynamic>>.from(itensList),
              ),
            ),
          );
        },
        label: Text('Importar',
            style: TextStyle(
              color: Colors.white,
            )),
        tooltip: 'Importar',
      ),
    );
  }
}
