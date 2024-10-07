import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const bool showImagesDebugLogError = false;

const _appTag = 'DBV Virtual';

class Log {
  static final key = GlobalKey<ScaffoldMessengerState>();

  final String tag;
  const Log(this.tag);

  static void snack(String texto, {
    bool isError = false,
    String actionLabel = 'Detalhes',
    void Function()? actionClick,
    bool persistent = false
  }) {
    try {
      key.currentState?.hideCurrentSnackBar();

      var snack = _snackBar(texto,
        isError: isError,
        actionLabel: actionLabel,
        actionClick: actionClick,
        persistent: persistent,
      );
      key.currentState?.showSnackBar(snack);
    } catch (ex) {
      const Log('Log').e('snackbar', ex);
    }
  }

  static SnackBar _snackBar(String texto, {
    bool isError = false,
    String actionLabel = '',
    void Function()? actionClick,
    bool persistent = false,
  }) {
    var tintColor = isError ? Colors.white : Colors.black;
    return SnackBar(
      content: SafeArea(
        child: GestureDetector(
          onTap: key.currentState?.hideCurrentSnackBar,
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isError ? Icons.clear : Icons.check, color: tintColor),
                const SizedBox(width: 12.0),
                Flexible(
                  child: Text(texto,
                    maxLines: 2,
                    style: TextStyle(
                      color: tintColor,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: isError ? Colors.red : Colors.white,
      showCloseIcon: actionClick == null,
      closeIconColor: tintColor,
      duration: Duration(seconds: persistent ? 1000 : 5),
      action: actionClick == null ? null :
      SnackBarAction(
        label: actionLabel,
        textColor: tintColor,
        onPressed: actionClick,
      ),
    );
  }

  void d(String metodo, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = '';
    if (value != null) msg += value.toString();
    if (value1 != null) msg += ': $value1';
    if (value2 != null) msg += ': $value2';
    if (value3 != null) msg += ': $value3';
    if (kDebugMode) {
      print('$_appTag D: $tag: $metodo: $msg');
    }
  }
  void e(String metodo, dynamic e, [dynamic value, dynamic value1, dynamic value2, dynamic value3]) {
    String msg = e.toString();
    if (value != null) msg += ': $value';
    if (value1 != null) msg += ': $value1';
    if (value2 != null) msg += ': $value2';
    if (value3 != null) msg += ': $value3';
    if (kDebugMode) {
      print('$_appTag E: $tag: $metodo: $msg');
    }

  }

}
