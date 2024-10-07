import 'package:flutter/material.dart';
import '../../../../provider/provider.dart';
import '../livro_add_page_base.dart';

class LivroAddPage extends LivroAddPageBase {
  const LivroAddPage({
    super.key,
    super.livro,
    super.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends LivroAddPageBaseState<LivroAddPage, LivrariaProvider> {

  @override
  String get pageTitle => 'Livro';

  @override
  String get keyPath => 'livraria';

}