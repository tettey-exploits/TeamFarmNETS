import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class ClassifyImage{
  late Interpreter interpreter;
  late Tensor inputTensor;
  late Tensor outputTensor;

  Future<void> loadModel() async {
    final options = InterpreterOptions();
    interpreter = await Interpreter.fromAsset('assets/afiricoco.tflite');
    inputTensor = interpreter.getInputTensors().first;
    outputTensor = interpreter.getOutputTensors().first;
  }

  Future<void> loadLabels() async {
    final labelTxt = await rootBundle.loadString('assets/labels.txt');
    final labels = labelTxt.split('\n');
  }

  Future<void> runInference(
      List<List<List<num>>> imageMatrix,
      ) async {

    loadModel();
    loadLabels();
    final input = [imageMatrix];
    final output = [List<int>.filled(1001, 0)];

    interpreter.run(input, output);
    final result = output.first;
  }

  List<List<int>> imgArray = [];
  var imageSize = 255;
  ByteBuffer bitmapToByteBuffer(ui.Image bitmap) {
    // Create a ByteData to hold the bytes
    final byteData = ByteData(4 * imageSize * imageSize * 3);
    final byteBuffer = byteData.buffer;
    final intValues = Int32List(imageSize * imageSize);
    // Get the pixels from the bitmap as Uint32List
    bitmap.toByteData(format: ui.ImageByteFormat.rawRgba).then((value) {
      final buffer = value?.buffer;
      final pixels = buffer?.asUint32List();
      int pixelIndex = 0;
      for (int i = 0; i < imageSize; i++) {
        for (int j = 0; j < imageSize; j++) {
          final val = pixels?[pixelIndex++]; // RGBA
          byteData.setFloat32((pixelIndex - 1) * 12, (val! >> 16 & 0xFF) / 255.0, Endian.host);
          byteData.setFloat32((pixelIndex - 1) * 12 + 4, (val >> 8 & 0xFF) / 255.0, Endian.host);
          byteData.setFloat32((pixelIndex - 1) * 12 + 8, (val & 0xFF) / 255.0, Endian.host);
        }
      }
    });
    return byteBuffer;
  }
}