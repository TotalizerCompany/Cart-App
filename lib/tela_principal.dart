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
  List<String> scannedBarcodes = [];  // Lista para armazenar os códigos de barras escaneados

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
            setState(() {
              scannedBarcodes.add(barcode.displayValue ?? '');
            });
            print('Código de barras detectado: ${barcode.displayValue}');
            print('lista com os codigos de barras: $scannedBarcodes');
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
      appBar: AppBar(
        title: const Text('Scanner de Códigos de Barras'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: scannedBarcodes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(scannedBarcodes[index]),
                );
              },
            )
          ),
          TextButton(onPressed: null, 
            child: const Text('Finalizar compra')
          )
        ],
      )
    );
  }
}
