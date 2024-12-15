import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/secondary_firebase.dart';
import 'package:uuid/uuid.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  _ImportScreenState createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? sessionId;
  String? userId;

  @override
  void initState() {
    super.initState();
    _generateSessionId();
  }

  // Função para gerar o sessionId único
  void _generateSessionId() {
    var uuid = Uuid();
    sessionId = uuid.v4();

    if (sessionId != null) {
      // Chama a função do SecondaryFirebaseService para salvar o sessionId
      SecondaryFirebaseService.saveSessionToFirestore(sessionId!);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: sessionId == null
            ? CircularProgressIndicator() // Exibe um carregamento enquanto é gerado o sessionId
            : FutureBuilder<FirebaseFirestore>(
                future: SecondaryFirebaseService.getSecondaryFirestore(),
                builder: (context, firestoreSnapshot) {
                  if (firestoreSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  if (firestoreSnapshot.hasData) {
                    final secondaryFirestore = firestoreSnapshot.data!;

                    return StreamBuilder<DocumentSnapshot>(
                      stream: secondaryFirestore
                          .collection('sessions')
                          .doc(sessionId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasData && snapshot.data != null) {
                          var doc = snapshot.data!;
                          var data = doc.data() as Map<String, dynamic>?;

                          if (data != null) {
                            bool authenticated = data['authenticated'] ?? false;
                            userId = data.containsKey('userId') ? data['userId'] : null;

                            if (authenticated && userId != null && userId!.isNotEmpty) {
                              return StreamBuilder<QuerySnapshot>(
                                stream: secondaryFirestore
                                    .collection(userId!)
                                    .doc('listas')
                                    .collection('lista_de_compras')
                                    .snapshots(),
                                builder: (context, listSnapshot) {
                                  if (listSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (listSnapshot.hasData && listSnapshot.data != null) {
                                    var items = listSnapshot.data!.docs;

                                    if (items.isEmpty) {
                                      return Text('Nenhuma lista encontrada.');
                                    }

                                    return ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        var item = items[index];
                                        var itemData = item.data() as Map<String, dynamic>;

                                        // Verifica se o campo 'itens' é uma lista
                                        if (itemData['itens'] is List) {
                                          var itensList = itemData['itens'] as List<dynamic>;

                                          // Cria uma lista interna para exibir os itens
                                          return ListView.builder(
                                            shrinkWrap: true, // Impede o erro de layout no ListView
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: itensList.length,
                                            itemBuilder: (context, index) {
                                              var currentItem = itensList[index];

                                              var itemNome = currentItem['nome'] ?? 'Sem nome';
                                              var itemQuantidade = currentItem['quantidade'] ?? 'Indefinido';

                                              return ListTile(
                                                title: Text(itemNome),
                                                subtitle: Text('Quantidade: $itemQuantidade'),
                                              );
                                            },
                                          );
                                        } else {
                                          return ListTile(
                                            title: Text('Itens não encontrados'),
                                            subtitle: Text(item.id),
                                          );
                                        }
                                      },
                                    );
                                  } else {
                                    return Text('Erro ao carregar as listas');
                                  }
                                },
                              );
                            } else {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  QrImageView(
                                    data: sessionId!,
                                    size: 200.0,
                                    version: QrVersions.auto,
                                    gapless: false,
                                  ),
                                  SizedBox(height: 20),
                                  Text('Aguardando autenticação...', textAlign: TextAlign.center),
                                ],
                              );
                            }
                          } else {
                            return Center(
                              child: Text('Erro ao carregar o documento do Firestore'),
                            );
                          }
                        } else {
                          return Center(
                            child: Text('Erro ao carregar o sessionId'),
                          );
                        }
                      },
                    );
                  } else {
                    return Center(
                      child: Text('Erro ao acessar o Firestore do segundo banco'),
                    );
                  }
                },
              ),
      ),
    );
  }
}
