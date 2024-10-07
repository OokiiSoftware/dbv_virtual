import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../provider/provider.dart';

class PdfViewPage extends StatelessWidget {
  final String title;
  final String pdfUrl;
  final bool showAppBar;
  final PdfViewerController? controller;
  final Widget? controllers;
  const PdfViewPage({
    super.key,
    this.title = 'PDF',
    required this.pdfUrl,
    this.showAppBar = true,
    this.controller,
    this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(title)) : null,
      body: Column(
        children: [
          if (controllers != null)
            controllers!,
          Expanded(child: body()),
        ],
      ),
    );
  }

  Widget body() {
    bool isWeb = pdfUrl.contains('http');

    if (!isWeb) {
      return SfPdfViewer.file(File(pdfUrl),
        controller: controller,
      );
    }

    if (InternetProvider.i.disconnected) {
      return const Center(
        child: Text('Sem conexão com a internet'),
      );
    }

    return SfPdfViewer.network(pdfUrl,
      controller: controller,
    );
  }

}