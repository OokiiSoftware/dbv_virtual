import 'package:flutter/material.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../util/util.dart';
import '../../../page.dart';
import '../biblioteca_page_base.dart';

class LivrariaPage extends BibliotecaPage {
  const LivrariaPage({
    super.key,
    super.readOnly,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends BibliotecaPageState<LivrariaPage, LivrariaProvider> {

  @override
  String get title => 'Livraria';

  @override
  String get addButtonText => 'Add Livro';

  @override
  void onItemTap(Livro value) {
    Navigate.push(context, LivroPage(livro: value, readOnly: readOnly));
  }

  @override
  void onAddTap([Livro? value]) {
    Navigate.push(context, LivroAddPage(livro: value, readOnly: readOnly,));
  }

}