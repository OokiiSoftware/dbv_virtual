import 'package:flutter/material.dart';
import '../../../../util/util.dart';
import '../../../page.dart';
import '../livro_page_base.dart';

class ManualPage extends LivroPageBase {
  const ManualPage({
    super.key,
    required super.livro,
    super.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends LivroPageBaseState<ManualPage> {

  @override
  String get pathToSave => 'manuais';

  @override
  void onEditTap() {
    Navigate.push(context, LivroAddPage(
      livro: livro.copy(),
      readOnly: readOnly,
    ));
  }

}