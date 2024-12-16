import 'package:flutter/material.dart';
import 'package:totalizer_cart/views/tela_qr_code.dart';
import 'package:totalizer_cart/components/bar_code.dart';

class TelaPrincipal extends StatefulWidget {
  final List<Map<String, dynamic>>? listaImportada;

  const TelaPrincipal({Key? key, this.listaImportada}) : super(key: key);

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final CameraSetup _cameraSetup = CameraSetup();
  final FirebaseService _firebaseService = FirebaseService();

  List<Map<String, dynamic>> scannedProducts = [];
  List<Map<String, dynamic>> importedList = [];
  Duration scanDelay = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    // Verifica se a lista foi importada
    if (widget.listaImportada != null) {
      importedList = widget.listaImportada!;
    }

    // Inicializa a câmera
    _cameraSetup.initializeCamera(onBarcodeScanned, scanDelay).then((_) {
      setState(() {});
    });
  }

  Future<void> onBarcodeScanned(String barcode) async {
    // Caso a lista seja importada, atualiza o progresso de escaneamento
    if (importedList.isNotEmpty) {
      final productData = importedList.firstWhere(
        (product) => product['id'] == barcode,
        orElse: () => {},
      );

      if (productData.isNotEmpty) {
        setState(() {
          final index = importedList.indexOf(productData);
          final currentQuantity =
              importedList[index]['quantidadeEscaneada'] ?? 0;
          final totalQuantity = importedList[index]['quantidade'] ?? 0;

          // Só aumenta a quantidade escaneada se não atingir o total
          if (currentQuantity < totalQuantity) {
            importedList[index]['quantidadeEscaneada'] = currentQuantity + 1;
          }
        });
      }
    } else {
      // Caso não tenha lista, adiciona produtos ao carrinho normalmente
      final productData = await _firebaseService.fetchProductByBarcode(barcode);

      if (productData != null) {
        final existingProductIndex =
            scannedProducts.indexWhere((product) => product['id'] == barcode);

        setState(() {
          if (existingProductIndex != -1) {
            scannedProducts[existingProductIndex]['quantidade'] += 1;
          } else {
            scannedProducts.add(productData);
          }
        });
      } else {
        print('Produto não encontrado.');
      }
    }
  }

  double calcularTotal() {
    return scannedProducts.fold(0.0, (total, produto) {
      return total + (produto['preco'] * produto['quantidade']);
    });
  }

  @override
  void dispose() {
    _cameraSetup.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Center(
        child: importedList.isNotEmpty
            ? _buildImportedListView()
            : _buildScannedProductsView(),
      ),
    );
  }

  Widget _buildScannedProductsView() {
    // Exibe os produtos escaneados (sem lista importada)
    return Center(
      child: Container(
        width: 900,
        height: 500,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.amber
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: scannedProducts.length,
                itemBuilder: (context, index) {
                  final product = scannedProducts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product['nome'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'R\$ ${product['preco'].toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  setState(() {
                                    if (product['quantidade'] > 1) {
                                      product['quantidade'] -= 1;
                                    } else {
                                      scannedProducts.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('${product['quantidade']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    product['quantidade'] += 1;
                                  });
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () {
                              setState(() {
                                scannedProducts.removeAt(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'TOTAL: R\$${calcularTotal().toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImportedListView() {
  // Exibe a lista importada
  return Center(
    child: Container(
      width: 900,
      height: 500,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.amber,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: importedList.length,
              itemBuilder: (context, index) {
                final product = importedList[index];
                final scanned = product['quantidadeEscaneada'] ?? 0;
                final total = product['quantidade'] ?? 0;
                final preco = product['preco'] ?? 0.0;
                final isChecked = scanned == total;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            border: isChecked
                                ? Border.all(color: Colors.green, width: 2)
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          // Marca o item e define a quantidade escaneada como o total
                                          importedList[index]
                                              ['quantidadeEscaneada'] = total;
                                        } else {
                                          // Desmarca o item e redefine a quantidade escaneada para zero
                                          importedList[index]
                                              ['quantidadeEscaneada'] = 0;
                                        }
                                      });
                                    },
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product['nome'] ?? 'Produto desconhecido',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          decoration: isChecked
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // Preço do produto
                                  Text(
                                    'R\$ ${preco.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      decoration: isChecked
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  // Botão para diminuir a quantidade escaneada
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (scanned > 0) {
                                          importedList[index]
                                                  ['quantidadeEscaneada'] =
                                              scanned - 1;
                                        }
                                      });
                                    },
                                  ),
                                  // Texto com a quantidade escaneada e total
                                  Text(
                                    '$scanned/$total',
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                  // Botão para aumentar a quantidade escaneada
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        if (scanned < total) {
                                          importedList[index]
                                                  ['quantidadeEscaneada'] =
                                              scanned + 1;
                                        }
                                      });
                                    },
                                  ),
                                  // Botão para remover o item da lista
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        importedList.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isChecked) // Adiciona a linha riscada quando o item for marcado se quiser remover o tirar esse if 
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                height: 1,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'TOTAL: R\$${_calculateImportedListTotal().toStringAsFixed(2)}',
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
          _buildConfirmButton(),
        ],
      ),
    ),
  );
}


  double _calculateImportedListTotal() {
    return importedList.fold(0.0, (total, product) {
      final preco = product['preco'] ?? 0.0;
      final scanned = product['quantidadeEscaneada'] ?? 0;
      return total + (preco * scanned);
    });
  }

  Widget _buildConfirmButton() {
    // Botão de confirmação para ambos os modos
    return GestureDetector(
      onTap: () {
        if (scannedProducts.isEmpty && importedList.isEmpty) {
          _showAlertDialog(context);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaQrCode(
                minhalista:
                    importedList.isNotEmpty ? importedList : scannedProducts,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 0, 0, 0),
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(15),
        child: const Text(
          'Confirmar produtos',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Carrinho vazio'),
          content: const Text('Por favor, adicione algum item ao carrinho'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
