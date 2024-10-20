import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_ml_vision/google_ml_vision.dart';

class TelaPrincipal extends StatefulWidget {
  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isDetecting = false;
  bool isCameraInitialized = false;
  final BarcodeDetector barcodeDetector = GoogleVision.instance.barcodeDetector();
  Duration scanDelay = const Duration(seconds: 2);


   // Lista para armazenar os códigos de barras escaneados
   List<Map<String, dynamic>> scannedProducts = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Obtém as câmeras disponíveis no dispositivo
    cameras = await availableCameras();

    // Inicializa a câmera traseira (câmera[0])
    _cameraController = CameraController(
      cameras![0],  /*Seleciona a primeira câmera (traseira) (OBS: qualidade da camera frontal muito baixa 
      para identificar o codigo de barras se quiser testa so substituir o 0 por 1)*/

      ResolutionPreset.high,  // Define a resolução como alta
    );

    try {
      // Inicializa o controlador da câmera
      await _cameraController!.initialize();
      setState(() {
        isCameraInitialized = true;  // Marca que a câmera foi inicializada
      });

      // Scan contínuo e reconhecimento dos códigos de barras
      _cameraController!.startImageStream((image) async {
        if (_isDetecting) return;

        _isDetecting = true;
        final GoogleVisionImage visionImage = GoogleVisionImage.fromBytes(
          image.planes[0].bytes,
          _buildMetaData(image, ImageRotation.rotation0),
        );
        List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);

        if (barcodes.isNotEmpty) {
          for (Barcode barcode in barcodes) {
            if(barcode.displayValue != null && barcode.displayValue!.isNotEmpty){
              await onBarcodeScanned(barcode.displayValue!);
            }
          }
          await Future.delayed(scanDelay);
        }

        _isDetecting = false;
      });
    } catch (e) {
      print('Erro ao inicializar a câmera: $e');
    }
  }

  GoogleVisionImageMetadata _buildMetaData(CameraImage image, ImageRotation rotation) {
    return GoogleVisionImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      rawFormat: image.format.raw,
      planeData: image.planes.map(
        (Plane plane) {
          return GoogleVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  //Conexãocom o fireStore
  Future<void> onBarcodeScanned(String barcode) async{
    //Tenta buscar o produto com o codigo de barras no banco no firebase
    final productDoc = await FirebaseFirestore.instance.collection('produtos').doc(barcode).get();

    if(productDoc.exists){
      //Verifica se o produto ja existe na lista
      final  existingProductIndex = scannedProducts.indexWhere((product) => product['id'] == barcode);

      if(existingProductIndex != -1){
        //Se o produto existir na lista, incrementa a quantidade
        setState(() {
          scannedProducts[existingProductIndex]['quantidade'] += 1;
        });
        //print no terminal para fim de testes
        print('quantidade atulizada ${scannedProducts[existingProductIndex]['nome']}: ${scannedProducts[existingProductIndex]['quantidade']}');
      }else{
        //produto que não esta na lista
        setState(() {
          scannedProducts.add({
            'id' : barcode,
            'nome' : productDoc['nome'],
            'preco' : productDoc['preco'],
            'quantidade' : 1,
          });
        });
        print('produto adicionado: ${productDoc['nome']}');
      }
    }else{
      print('produto não encontrado');
    } 
  }

  @override
  void dispose() {
    // Libera os recursos da câmera
    _cameraController?.dispose();
    barcodeDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: scannedProducts.length,
              itemBuilder: (context, index) {
                final product = scannedProducts[index];  // Objeto do produto na lista
                return ListTile(
                  title: Text(product['nome']),
                  subtitle: Text('Preço: R\$${product['preco']}'),
                  trailing: Text('Quantidade: ${product['quantidade']}'),
                );
              },
            )
          ),
          const ElevatedButton(onPressed: null, 
            child: Text('Finalizar compra')
          )
        ],
      )
    );
  }
}
