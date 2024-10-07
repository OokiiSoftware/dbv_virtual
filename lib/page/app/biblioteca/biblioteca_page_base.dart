import 'package:dbv_virtual/page/app/pages_base/page_base_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';

abstract class BibliotecaPage extends StatefulWidget {
  final bool readOnly;
  const BibliotecaPage({
    super.key,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState();
}
abstract class BibliotecaPageState<
T extends BibliotecaPage, P extends BibliotecaProviderBase> extends StateListPage<T> {

  bool get readOnly => widget.readOnly;
  String get addButtonText;

  late P provider;

  @override
  String? get custonTitle => title;

  @override
  void initState() {
    provider = context.read<P>();
    super.initState();
  }

  @override
  Widget builder() {
    provider = context.watch<P>();
    final list = provider.data.values.toList();
    list.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    final pageWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = pageWidth ~/ 150;

    return GridView.builder(
      itemCount: list.length,
      padding: EdgeInsets.only(bottom: list.length.isEven ? 80 : 10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
        childAspectRatio: 1/1.9,
      ),
      itemBuilder: (context, i) {
        final item = list[i];

        return LivroGridTile(
          key: ValueKey(item),
          livro: item,
          readOnly: readOnly,
          onTap: onItemTap,
          onEditTap: onAddTap,
        );
      },
    );
  }

  @override
  Widget? actionButton() {
    if (!loaded) return const CircularProgressIndicator();

    if (readOnly) return null;

    return FloatingActionButton.extended(
      onPressed: onAddTap,
      label: Text(addButtonText),
    );
  }

  @override
  Future<void> fufureVoid() async {
    if (InternetProvider.i.disconnected) {
      return;
    }
    await provider.loadOnline();
  }

  @override
  Future<bool> onRefresh() async {
    if (!await super.onRefresh()) {
      return false;
    }

    try {
      await provider.refresh();
    } catch(e) {
      Log.snack(e.toString(), isError: true);
    }

    return true;
  }


  void onItemTap(Livro value);

  void onAddTap([Livro? value]);
}