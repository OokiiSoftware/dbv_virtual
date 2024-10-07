import 'package:flutter/material.dart';
import '../../../../provider/provider.dart';
import '../livro_add_page_base.dart';

class ManualAddPage extends LivroAddPageBase {
  const ManualAddPage({
    super.key,
    super.livro,
    super.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends LivroAddPageBaseState<ManualAddPage, ManuaisProvider> {

  @override
  String get pageTitle => 'Manual';

  @override
  String get keyPath => 'manuais';

}