import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/provider.dart';
import '../../../../model/model.dart';
import '../../../../util/util.dart';
import '../../../../res/res.dart';
import 'especialidade_page.dart';

class EspecialidadesPage extends StatefulWidget {
  final String areatype;
  final bool readOnly;
  const EspecialidadesPage({
    super.key,
    required this.areatype,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<EspecialidadesPage> {

  EspecialidadesProvider _provider = EspecialidadesProvider.i;

  String get areaId => widget.areatype;
  bool get readOnly => widget.readOnly;

  @override
  Widget build(BuildContext context) {
    _provider = context.watch<EspecialidadesProvider>();
    final list = _provider.getAllByType(areaId);
    list.sort((a, b) => a.nome.compareTo(b.nome));

    String title = 'Especialidades';
    if (list.isNotEmpty) {
      title = list.first.area;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.separated(
        itemCount: list.length,
        padding: const EdgeInsets.only(bottom: 50),
        itemBuilder: (context, i) {
          final item = list[i];

          return EspecialidadeTile(
            key: ValueKey(item),
            especialidade: item,
            onTap: _onItemTap,
          );
        },
        separatorBuilder: (context, i) => const SizedBox(height: 2),
      ),
    );
  }

  void _onItemTap(Especialidade value) async {
    Navigate.push(context, EspecialidadePage(especialidade: value));
  }

}