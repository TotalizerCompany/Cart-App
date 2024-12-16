import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:totalizer_cart/views/lista_detalhada.dart';
import '../services/secondary_firebase.dart';
import 'package:uuid/uuid.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  String? sessionId;
  String? userId;

  @override
  void initState() {
    super.initState();
    _generateSessionId();
  }

  void _generateSessionId() {
    var uuid = Uuid();
    sessionId = uuid.v4();

    if (sessionId != null) {
      SecondaryFirebaseService.saveSessionToFirestore(sessionId!);
    }

    setState(() {});
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
        
      ),
      body: Center(
        child: sessionId == null
            ? CircularProgressIndicator()
            : FutureBuilder<FirebaseFirestore>(
                future: SecondaryFirebaseService.getSecondaryFirestore(),
                builder: (context, firestoreSnapshot) {
                  if (firestoreSnapshot.connectionState ==
                      ConnectionState.waiting) {
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasData && snapshot.data != null) {
                          var doc = snapshot.data!;
                          var data = doc.data() as Map<String, dynamic>?;

                          if (data != null) {
                            bool authenticated = data['authenticated'] ?? false;
                            userId = data.containsKey('userId')
                                ? data['userId']
                                : null;

                            if (authenticated &&
                                userId != null &&
                                userId!.isNotEmpty) {
                              return StreamBuilder<QuerySnapshot>(
                                stream: secondaryFirestore
                                    .collection(userId!)
                                    .doc('listas')
                                    .collection('lista_de_compras')
                                    .snapshots(),
                                builder: (context, listSnapshot) {
                                  if (listSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  if (listSnapshot.hasData &&
                                      listSnapshot.data != null) {
                                    var items = listSnapshot.data!.docs;

                                    if (items.isEmpty) {
                                      return Text('Nenhuma lista encontrada.');
                                    }

                                    return ListView.builder(
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        var item = items[index];
                                        var itemData =
                                            item.data() as Map<String, dynamic>;

                                        String displayTitle = itemData['titulo']
                                                    ?.isNotEmpty ??
                                                false
                                            ? itemData[
                                                'titulo'] // Se o título não estiver vazio, exibe o título
                                            : item.id;

                                        return ListTile(
                                          title: Text(displayTitle),
                                          subtitle: Text(
                                              'Itens: ${itemData['itens']?.length ?? 0}'),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ListaDetalhadaScreen(
                                                  listaId: displayTitle,
                                                  listaData: itemData,
                                                ),
                                              ),
                                            );
                                          },
                                        );
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
                                  Text('Aguardando autenticação...',
                                      textAlign: TextAlign.center),
                                ],
                              );
                            }
                          } else {
                            return Center(
                              child: Text(
                                  'Erro ao carregar o documento do Firestore'),
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
                      child:
                          Text('Erro ao acessar o Firestore do segundo banco'),
                    );
                  }
                },
              ),
      ),
    );
  }
}
