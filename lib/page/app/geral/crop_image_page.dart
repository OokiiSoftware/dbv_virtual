import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:crop_image/crop_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../res/res.dart';
import '../../../util/logs.dart';

class CropImagePage extends StatefulWidget {
  final String inPath;
  final String outPath;
  final double? ratio;
  final bool canChangeRadio;
  const CropImagePage({
    super.key,
    required this.inPath,
    required this.outPath,
    this.ratio,
    this.canChangeRadio = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<CropImagePage> {

  String get inPath => widget.inPath;
  String get outPath => widget.outPath;
  double? get ratio => widget.ratio;

  final controller = CropController(
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recortar imagen'),
      ),
      body: CropImage(
        controller: controller,
        image: Image.file(File(inPath)),
      ),
      bottomNavigationBar: _buildButtons(),
    );
  }

  Widget _buildButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      TextButton(
        child: const Text('Resetar'),
        onPressed: () {
          controller.rotation = CropRotation.up;
          controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
          controller.aspectRatio = 1.0;
        },
      ),
      if (widget.canChangeRadio)
        IconButton(
          icon: const Icon(Icons.aspect_ratio),
          onPressed: _aspectRatios,
        ),
      IconButton(
        icon: const Icon(Icons.rotate_90_degrees_ccw_outlined),
        onPressed: _rotateLeft,
      ),
      IconButton(
        icon: const Icon(Icons.rotate_90_degrees_cw_outlined),
        onPressed: _rotateRight,
      ),
      TextButton(
        onPressed: _finished,
        child: const Text('Concluir'),
      ),
    ],
  );


  void _init() async {
    await Future.delayed(const Duration(milliseconds: 400));
    controller.aspectRatio = ratio;
  }

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Selecionar aspect ratio'),
          children: [
            // special case: no aspect ratio
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1.0),
              child: const Text('Livre'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: const Text('Quadrado'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: const Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1 / 2),
              child: const Text('1:2'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: const Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: const Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value == -1 ? null : value;
      controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }

  Future<void> _rotateLeft() async => controller.rotateLeft();

  Future<void> _rotateRight() async => controller.rotateRight();

  Future<void> _finished() async {
    var image = await controller.croppedImage(quality: FilterQuality.low);
    if (!mounted) return;

    final res = await DialogBox(
      context: context,
      title: 'Sua imagem está OK?',
      contentPadding: EdgeInsets.zero,
      content: [
        image,
      ],
    ).simNao();
    if (!res.isPositive || !mounted) return;

    bool cancelado = false;

    DialogBox(
      context: context,
      dismissible: false,
      content: const [
        Text('Comprimindo imagem'),
        Text('Por favor, aguarde, pode demorar alguns segundos dependendo do tamanho da imagem.'),
        SizedBox(height: 5),
        LinearProgressIndicator(),
      ],
    ).cancel().then((res) {
      if (res.isNegative) {
        cancelado = true;
      }
    });
    await Future.delayed(const Duration(milliseconds: 300));

    image = await controller.croppedImage(quality: FilterQuality.low);

    try {
      final param = ImageFileConfiguration(
        input: ImageFile(
          filePath: outPath,
          rawBytes: await convertImageToUint8List(image.image),
        ),
        config: const Configuration(quality: 20),
      );
      final output = await compressor.compress(param);
      final file = await File(outPath).writeAsBytes(output.rawBytes);

      if (mounted) {
        if (!cancelado) Navigator.pop(context);

        Navigator.pop(context, file.path);
      }
    } catch(e) {
      if (!cancelado && mounted) Navigator.pop(context);
      Log.snack('Erro ao obter imagem', isError: true);
      const Log('CropImagePage').e('_finished', e);
    }

  }

  Future<Uint8List> convertImageToUint8List(ImageProvider imageProvider) async {
    // Create an ImageStream.
    final ImageStream stream = imageProvider.resolve(ImageConfiguration.empty);

    // Completer to handle the asynchronous operation.
    final Completer<ui.Image> completer = Completer();

    // Listen to the stream of images.
    ImageStreamListener? listener;
    listener = ImageStreamListener(
          (ImageInfo image, bool synchronousCall) {
        // Complete with the image when it's available.
        completer.complete(image.image);

        // Remove the listener once the image is received.
        if (listener != null) {
          stream.removeListener(listener);
        }
      },
      onError: (dynamic exception, StackTrace? stackTrace) {
        // Handle errors, e.g., by completing with an error.
        completer.completeError(exception, stackTrace);

        // Remove the listener on error as well.
        if (listener != null) {
          stream.removeListener(listener);
        }
      },
    );

    // Add the listener to the stream.
    stream.addListener(listener);

    // Await the image.
    final ui.Image image = await completer.future;

    // Convert the image to a byte array.
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8list = byteData!.buffer.asUint8List();

    return uint8list;
  }
}
