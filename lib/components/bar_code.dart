import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class CameraSetup {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isDetecting = false;
  bool isCameraInitialized = false;
  final BarcodeScanner barcodeScanner = BarcodeScanner();

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<void> initializeCamera(Function onBarcodeScanned, Duration scanDelay) async {
    try {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420, // Use yuv420_888 for Android
      );

      await cameraController!.initialize();
      isCameraInitialized = true;

      cameraController!.startImageStream((image) async {
        if (isDetecting) return;
        isDetecting = true;

        try {
          final inputImage = await _inputImageFromCameraImage(image);
          if (inputImage != null) {
            final barcodes = await barcodeScanner.processImage(inputImage);
            if (barcodes.isNotEmpty) {
              for (Barcode barcode in barcodes) {
                if (barcode.displayValue != null && barcode.displayValue!.isNotEmpty) {
                  print('Código de barras escaneado: ${barcode.displayValue}');
                  await onBarcodeScanned(barcode.displayValue!);
                }
              }
              await Future.delayed(scanDelay);
            }
          }
        } catch (e) {
          print('Erro ao processar a imagem: $e');
        } finally {
          isDetecting = false;
        }
      });
    } catch (e) {
      print('Erro ao inicializar a câmera: $e');
    }
  }

  Future<InputImage?> _inputImageFromCameraImage(CameraImage image) async {
    // Obtém a rotação do sensor da câmera
    final camera = cameras![0]; // Assumindo que você tem apenas uma câmera
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    // Calcular a rotação com base no dispositivo (Android/iOS)
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    // Verificar o formato da imagem
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    print("Formato de imagem (raw): ${image.format.raw}");
    print("Formato de imagem (detected): $format");

    // Se o formato for yuv420_888, converta para NV21
    if (format == InputImageFormat.yuv_420_888) {
      final bytes = _convertYuv420ToNv21(image);
      if (bytes.isEmpty) {
        print("Erro ao converter YUV420 para NV21.");
        return null;
      }

      // Retornar a imagem convertida para InputImage
      return InputImage.fromBytes(
        bytes: Uint8List.fromList(bytes),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation, // Usado apenas no Android
          format: InputImageFormat.nv21, // Defina o formato como NV21
          bytesPerRow: image.planes[0].bytesPerRow, // Necessário para a iOS
        ),
      );
    }

    // Caso contrário, se não for um formato suportado, retornar null
    print("Formato de imagem não suportado.");
    return null;
  }

  // Converte YUV420 para NV21
  List<int> _convertYuv420ToNv21(CameraImage image) {
    try {
      final yPlane = image.planes[0];
      final uPlane = image.planes[1];
      final vPlane = image.planes[2];

      final y = yPlane.bytes;
      final u = uPlane.bytes;
      final v = vPlane.bytes;

      final nv21Bytes = <int>[];

      // Copia a plane Y (luminância)
      nv21Bytes.addAll(y);

      // Alterna os planos U e V (crominância)
      for (int i = 0; i < u.length; i++) {
        nv21Bytes.add(v[i]);
        nv21Bytes.add(u[i]);
      }

      return nv21Bytes;
    } catch (e) {
      print('Erro ao converter YUV420 para NV21: $e');
      return [];
    }
  }

  void dispose() {
    cameraController?.dispose();
    barcodeScanner.close();
  }
}

class FirebaseService {
  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    try {
      final productDoc = await FirebaseFirestore.instance.collection('produtos').doc(barcode).get();
      if (productDoc.exists) {
        return {
          'id': barcode,
          'nome': productDoc['nome'],
          'preco': productDoc['preco'],
          'quantidade': 1,
        };
      } else {
        print('Produto não encontrado no Firebase: $barcode');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar produto no Firebase: $e');
      return null;
    }
  }
}
