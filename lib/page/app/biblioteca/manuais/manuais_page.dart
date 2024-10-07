import 'package:flutter/material.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../util/util.dart';
import '../../../page.dart';
import '../biblioteca_page_base.dart';

class ManuaisPage extends BibliotecaPage {
  const ManuaisPage({
    super.key,
    super.readOnly,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends BibliotecaPageState<ManuaisPage, ManuaisProvider> {

  @override
  String get title => 'Guias e Manuais';

  @override
  String get addButtonText => 'Add Manual';

  @override
  void onItemTap(Livro value) {
    Navigate.push(context, ManualPage(livro: value, readOnly: readOnly));
  }

  @override
  void onAddTap([Livro? value]) {
    Navigate.push(context, ManualAddPage(livro: value, readOnly: readOnly,));
  }

}