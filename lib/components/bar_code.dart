import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

class CameraSetup {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isDetecting = false;
  bool isCameraInitialized = false;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  Future<void> initializeCamera({
    required Function(String barcode) onBarcodeScanned,
    required Duration scanDelay,
  }) async {
    try {
      // Inicializa a lista de câmeras disponíveis
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        throw CameraException('NoCameraFound', 'Nenhuma câmera disponível.');
      }

      // Configura o controlador da câmera
      _cameraController = CameraController(
        _cameras!.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Inicializa a câmera
      await _cameraController!.initialize();
      isCameraInitialized = true;

      // Inicia o fluxo de captura de imagens
      _startImageStream(onBarcodeScanned, scanDelay);
    } catch (e) {
      print('Erro ao inicializar a câmera: $e');
    }
  }

  void _startImageStream(Function(String barcode) onBarcodeScanned, Duration scanDelay) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    _cameraController!.startImageStream((image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final inputImage = await _convertToInputImage(image);
        if (inputImage != null) {
          // Processa a imagem para detectar códigos de barras
          final barcodes = await _barcodeScanner.processImage(inputImage);
          if (barcodes.isNotEmpty) {
            for (Barcode barcode in barcodes) {
              final barcodeValue = barcode.displayValue;
              if (barcodeValue != null && barcodeValue.isNotEmpty) {
                // Reproduz som ao escanear o código
                await _playSound();

                print('Código de barras escaneado: $barcodeValue');
                await onBarcodeScanned(barcodeValue);
                break; // Interrompe o loop após processar o primeiro código válido
              }
            }
            await Future.delayed(scanDelay); // Adiciona atraso antes de processar outro frame
          }
        }
      } catch (e) {
        print('Erro ao processar a imagem: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<InputImage?> _convertToInputImage(CameraImage image) async {
    try {
      // Obtém a rotação do sensor da câmera
      final sensorOrientation = _cameras![0].sensorOrientation;
      InputImageRotation? rotation = _getImageRotation(sensorOrientation);

      if (rotation == null) return null;

      // Verifica o formato da imagem
      final format = InputImageFormatValue.fromRawValue(image.format.raw);
      print("Formato de imagem (raw): ${image.format.raw}");
      print("Formato de imagem (detected): $format");

      // Se o formato for yuv420_888, converte para NV21
      if (format == InputImageFormat.yuv_420_888) {
        final bytes = _convertYuv420ToNv21(image);
        if (bytes.isEmpty) {
          print("Erro ao converter YUV420 para NV21.");
          return null;
        }

        // Retorna a imagem convertida para InputImage
        return InputImage.fromBytes(
          bytes: Uint8List.fromList(bytes),
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation, // Usado apenas no Android
            format: InputImageFormat.nv21, // Define o formato como NV21
            bytesPerRow: image.planes[0].bytesPerRow, // Necessário para a iOS
          ),
        );
      }

      // Caso contrário, se não for um formato suportado, retorna null
      print("Formato de imagem não suportado.");
      return null;
    } catch (e) {
      print('Erro ao converter imagem para InputImage: $e');
      return null;
    }
  }

  InputImageRotation? _getImageRotation(int sensorOrientation) {
    // Calcular a rotação com base no dispositivo (Android/iOS)
    if (Platform.isIOS) {
      return InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      final rotationCompensation = _orientations[_cameraController!.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      final correctedRotation = _cameras![0].lensDirection == CameraLensDirection.front
          ? (sensorOrientation + rotationCompensation) % 360
          : (sensorOrientation - rotationCompensation + 360) % 360;

      return InputImageRotationValue.fromRawValue(correctedRotation);
    }
    return null;
  }

  // Converte YUV420 para NV21
  List<int> _convertYuv420ToNv21(CameraImage image) {
    try {
      final y = image.planes[0].bytes;
      final u = image.planes[1].bytes;
      final v = image.planes[2].bytes;

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

  Future<void> _playSound() async {
  try {
    print("Tentando reproduzir o som...");
    await _audioPlayer.setAsset('assets/sounds/beep.mp3');
    await _audioPlayer.play();
    print("Som reproduzido com sucesso!");
  } catch (e) {
    print('Erro ao reproduzir o som: $e');
  }
}

  void dispose() {
    _cameraController?.dispose();
    _barcodeScanner.close();
  }
}

class FirebaseService {
  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    try {
      // Busca o produto no Firestore pela chave do código de barras
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
