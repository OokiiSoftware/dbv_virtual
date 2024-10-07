import 'package:flutter/material.dart';
import '../../../../util/util.dart';
import '../../../page.dart';
import '../livro_page_base.dart';

class LivroPage extends LivroPageBase {
  const LivroPage({
    super.key,
    required super.livro,
    super.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends LivroPageBaseState<LivroPage> {

  @override
  String get pathToSave => 'livros';

  @override
  void onEditTap() {
    Navigate.push(context, LivroAddPage(
      livro: livro.copy(),
      readOnly: readOnly,
    ));
  }

}