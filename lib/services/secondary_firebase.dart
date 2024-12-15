import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

class SecondaryFirebaseService {
  static FirebaseFirestore? _secondaryFirestore;

  static Future<FirebaseFirestore> getSecondaryFirestore() async {
    if (_secondaryFirestore == null) {
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: SecondaryFirebaseOptions.currentPlatform,
      );
      _secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
    }
    return _secondaryFirestore!;
  }
  //Função para salvar o sessionID no FireStore
  static Future<void> saveSessionToFirestore(String sessionId) async {
    try {
      FirebaseFirestore secondaryFirestore = await getSecondaryFirestore();

      await secondaryFirestore.collection('sessions').doc(sessionId).set({
        'createdAt': Timestamp.now(),
        'authenticated': true,
      });

      print("SessionId salvo no FireStore");
    } catch (e) {
      print("Erro ao salvar o sessionId no FireStore: $e");
    }
  }
}