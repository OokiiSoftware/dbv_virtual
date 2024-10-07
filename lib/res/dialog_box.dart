import 'package:flutter/material.dart';

class DialogBox {
  final BuildContext context;
  final String? title;
  final String auxBtnText;
  final String? positiveButtonText;
  final String? negativeButtonText;
  final bool dismissible;
  final List<Widget> content;
  final EdgeInsets contentPadding;
  final List<Widget> Function(BuildContext, StateSetter)? builder;
  final Future<List<Widget>> Function()? future;
  DialogBox({
    required this.context,
    this.title,
    this.auxBtnText = '',
    this.positiveButtonText,
    this.negativeButtonText,
    this.dismissible = true,
    this.content = const [],
    this.contentPadding = const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
    this.builder,
    this.future,
  }) : assert((content.isEmpty || builder == null) &&
      (content.isEmpty || future == null) &&
      (builder == null || future == null),
  'content, builder ou future, só pode usar um dos dois');

  Future<DialogResult> none() async {
    return await _aux(dismissible: dismissible,);
  }

  Future<DialogResult> simNao() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(negativeButtonText ??'Não'),
        positiveButton(positiveButtonText ?? 'Sim'),
      ],
    );
  }
  Future<DialogResult> simNaoCancel() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        noneButton('Cancelar'),
        negativeButton(negativeButtonText ?? 'Não'),
        positiveButton(positiveButtonText ?? 'Sim'),
      ],
    );
  }

  Future<DialogResult> cancelOK() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(negativeButtonText ?? 'Cancelar'),
        positiveButton(positiveButtonText ?? 'OK'),
      ],
    );
  }

  Future<DialogResult> ok() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        positiveButton(positiveButtonText ?? 'OK'),
      ],
    );
  }

  Future<DialogResult> cancel() async {
    return await _aux(
      dismissible: dismissible,
      actions: [
        negativeButton(negativeButtonText ?? 'Cancelar'),
      ],
    );
  }

  Future<DialogResult> _aux({List<Widget>? actions, bool dismissible = true}) async {
    Widget child() {
      if (future != null) {
        return FutureBuilder<List<Widget>>(
        future: future?.call(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: LinearProgressIndicator());
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: snapshot.requireData,
          );
        },
      );
      }

      if (builder != null) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: builder!.call(context, setState),
            );
          },
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: content,
      );
    }

    return await showDialog<DialogResult>(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => AlertDialog(
        title: title == null ? null : Text(title ?? ''),
        content: SingleChildScrollView(
          child: child(),
        ),
        contentPadding: contentPadding,
        actions: actions,
        actionsAlignment: MainAxisAlignment.spaceBetween,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ) ?? DialogResult.none;
  }

  Widget noneButton(String text) => TextButton(
    onPressed: () => Navigator.pop(context, DialogResult.none),
    child: Text(text),
  );

  Widget negativeButton(String text) => TextButton(
    onPressed: () => Navigator.pop(context, DialogResult.negative),
    child: Text(text),
  );

  Widget positiveButton(String text) => TextButton(
    onPressed: () => Navigator.pop(context, DialogResult.positive),
    child: Text(text),
  );
}

class DialogResult {
  static const int noneValue = -10;
  static const int positiveValue = 122;
  static const int negativeValue = 2252;

  final int value;
  DialogResult(this.value);

  static DialogResult get none => DialogResult(noneValue);
  static DialogResult get positive => DialogResult(positiveValue);
  static DialogResult get negative => DialogResult(negativeValue);

  bool get isPositive => value == positiveValue;
  bool get isNegative => value == negativeValue;
  bool get isNone => value == noneValue;
}

class DialogFullScreen {
  final BuildContext context;
  final bool showCloseButton;
  final Widget content;
  final MainAxisAlignment alignment;
  DialogFullScreen({required this.context, required this.content, this.alignment = MainAxisAlignment.start,
    this.showCloseButton = true});

  Future<dynamic> show() async {
    return await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) {
        return SizedBox.expand( // makes widget fullscreen
          child: Stack(
            children: [
              content,
              if (showCloseButton)...[
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 60),
                    child: FloatingActionButton.extended(
                      label: const Text('FECHAR'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Future<dynamic> showPage() async {
    return await showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(0.3),
      pageBuilder: (context, anim1, anim2) {
        return content;
      },
    );
  }
}
