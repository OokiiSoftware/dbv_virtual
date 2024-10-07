import 'package:flutter/material.dart';
import '../provider/provider.dart';
import '../../model/model.dart';
import '../../res/res.dart';
import '../page/page.dart';
import '../util/util.dart';

class Popup {
  final BuildContext context;
  Popup(this.context);

  Future<bool> delete() async {
    final res = await DialogBox(
      context: context,
      title: 'Remover',
      content: [
        const Text('Essa ação não poderá ser desfeita, deseja continuar?'),
      ],
    ).simNao();

    return res.isPositive;
  }

  void errorDetalhes(dynamic e) {
    DialogBox(
      context: context,
      title: 'Detalhes do erro',
      content: [
        Text(e.toString()),
      ],
    ).ok();
  }

  Future<Map<String, Especialidade>?> especialidade(List<String> selecteds) async {
    final espProv = EspecialidadesProvider.i;
    if (!espProv.loadedOnline) {
      bool cancelado = false;
      DialogBox(
        context: context,
        dismissible: false,
        content: const [
          Text('Obtendo especialidades'),
          LinearProgressIndicator(),
        ],
      ).cancel().then((e) => cancelado = e.isNegative);

      await espProv.loadOnline();
      if (cancelado || !context.mounted) return null;
      Navigator.pop(context);
    }

    if (!context.mounted) return null;

    return await showSearch(
      context: context,
      delegate: EspecialidadeDataSearch(
        showOnEmpty: true,
        multiSelect: true,
        selecteds: selecteds,
      ),
    );
  }

  Future<Map<String, ClasseItem>> classe([List<String>? selecteds]) async {
    Map<String, ClasseItem> classes = {};
    Arrays.classes.forEach((key, value) {
      final item = ClasseItem(cod: key, nome: value);
      item.selected = selecteds?.contains(item.id) ?? false;
      classes[item.id] = item;
    });

    final res = await DialogBox(
      context: context,
      dismissible: false,
      title: 'Classes',
      builder: (context, setState) {
        bool allSelected = classes.values.where((e) => e.selected).length == classes.length;
        return [
          CheckboxListTile(
            title: Text(allSelected ? 'Desmarcar tudo' : 'Selecionar tudo'),
            value: allSelected,
            onChanged: (value) {
              for (var c in classes.values) {
                c.selected = value!;
              }
              setState(() {});
            },
          ),
          const Divider(),

          for(var c in classes.values)...[
            ClasseItemTile(
              key: ValueKey(c),
              classe: c,
              onTap: (value) {
                value.selected = !value.selected;
                setState(() {});
              },
              trailing: Checkbox(
                value: c.selected,
                onChanged: (value) {
                  c.selected = value!;
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 3)
          ],
        ];
      },
    ).cancelOK();
    if (!res.isPositive) return {};

    return classes..removeWhere((key, value) => !value.selected);
  }

  Future<DateTime?> dateTime(String time, {String? min, String? max}) async {
    final first = Formats.stringToDateTime(min) ?? DateTime(1900);
    final now = DateTime.now();
    final last = Formats.stringToDateTime(max) ?? now;
    var date  = Formats.stringToDateTime(time) ?? now;

    if (date.year < first.year) {
      date = last;
    }

    return await showDatePicker(
      context: context,
      firstDate: first,
      lastDate: last,
      currentDate: date,
    );
  }

  Future<bool> msg(String text) async {
    final res = await DialogBox(
      context: context,
      content: [
        Text(text),
      ],
    ).ok();

    return res.isPositive;
  }

}