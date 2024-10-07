import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class SgcAddClassePage extends StatefulWidget {
  const SgcAddClassePage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcAddClassePage> with SingleTickerProviderStateMixin {

  final _log = const Log('SgcAddClassePage');

  final Map<String, Membro> _membros = {};
  final Map<String, ClasseItem> _classes = {};

  final _formKey = GlobalKey<FormState>();

  String _instrutor = '';

  late final _tabController = TabController(length: 2, vsync: this);
  final _pageController = PageController(viewportFraction: .9);

  final _dataController = MaskedTextController(mask: Masks.date);

  bool _inProgress = false;

  @override
  Widget build(BuildContext context) {
    final membrosList = _membros.values.toList();
    final espList = _classes.values.toList();

    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Atribuir Classes'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (i) {
            _pageController.animateToPage(i,
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
            );
          },
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Membros (${_membros.length})',),
            Tab(text: 'Classes (${_classes.length})',),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_inProgress)
              const LinearProgressIndicator(),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) {
                  _tabController.index = i;
                  _setState();
                },
                children: [
                  ListView(
                    children: [
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectMembro,
                          child: const Text('Add Membro'),
                        ),
                      ),  // add

                      Card(
                        child: ListView.separated(
                          itemCount: _membros.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            final item = membrosList[i];
                            return MembroTile(
                              key: ValueKey(item),
                              membro: item,
                              enabled: false,
                              dense: true,
                              trailing: IconButton(
                                onPressed: () => _onRemoveMembroTap(item),
                                icon: const Icon(Icons.delete_forever,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, i) => const SizedBox(height: 2),
                        ),
                      ),  // list
                    ],
                  ),

                  ListView(
                    children: [
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectEspecialidade,
                          child: const Text('Add Classe'),
                        ),
                      ),  // add

                      Card(
                        child: ListView.separated(
                          itemCount: _classes.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            final item = espList[i];
                            return ClasseItemTile(
                              key: ValueKey(item),
                              classe: item,
                              enabled: false,
                              trailing: IconButton(
                                onPressed: () => _onRemoveEspTap(item),
                                icon: const Icon(Icons.delete_forever),
                              ),
                            );
                          },
                          separatorBuilder: (context, i) => const SizedBox(height: 2),
                        ),
                      ),  // list
                    ],
                  ),
                ],
              ),
            ),

            TextFormField(
              keyboardType: TextInputType.name,
              inputFormatters: TextType.name.upperCase.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Instrutor',
              ),
              validator: Validators.obrigatorio,
              onSaved: (value) => _instrutor = value!,
            ),  // instrutor

            TextFormField(
              controller: _dataController,
              inputFormatters: TextType.data.inputFormatters,
              decoration: InputDecoration(
                labelText: 'Data de conclusão',
                suffixIcon: IconButton(
                  onPressed: _onDateTap,
                  icon: const Icon(Icons.calendar_month),
                ),
              ),
              validator: Validators.dataObrigatorio,
            ),  // data

            const SizedBox(height: 10),

            SizedBox(
              height: 40,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onSaveTap,
                child: const Text('Salvar'),
              ),
            ),  // salvar

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _onSaveTap() async {
    if (_membros.isEmpty) {
      Log.snack('Selecione um ou mais membros', isError: true);
      return;
    }
    if (_classes.isEmpty) {
      Log.snack('Selecione uma ou mais classes', isError: true);
      return;
    }

    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    _setInProgress(true);

    try {
      int codClube = ClubeProvider.i.clube.codigo;
      if (codClube == 0) {
        codClube = await SgcProvider.i.getCodClube();
        if (codClube == 0) throw 'clubeCod == null';

        ClubeProvider.i.setCodigo(codClube);
      }

      final body = {
        'instrutor': _instrutor,
        'dt_termino': _dataController.text,
        'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
        'cod_autor': FirebaseProvider.i.user.codUsuario,
        'cod_clube': codClube,
      };

      await SgcProvider.i.enviarClasses(
          _membros.values.toList(), _classes.values.toList(), body);

      Log.snack('Dados Salvos');
      if (mounted) {
        Navigator.pop(context);
      }
    } catch(e) {
      Log.snack('Erro ao enviar os dados', isError: true);
      _log.e('_onSaveTap', e);
    }
    _setInProgress(false);
  }

  void _selectMembro() async {
    final res = await Navigate.push(context, const MembrosPage2(multselect: true));
    if (res is! List<Membro> || !mounted) return;

    for (var e in res) {
      e.selected = false;
      if (e.id == FirebaseProvider.i.user.id) {
        DialogBox(
          context: context,
          dismissible: false,
          content: const [
            Text('Você não pode atribuir classes a si mesmo.'),
          ],
        ).ok();
        continue;
      }
      _membros[e.id] = e;
    }
    _setState();
  }

  void _selectEspecialidade() async {
    final item = await Popup(context).classe(_classes.keys.toList());
    if (item.isEmpty) return;

    _classes.clear();
    _classes.addAll(item);
    _setState();
  }

  void _onRemoveMembroTap(Membro value) {
    _membros.remove(value.id);
    _setState();
  }

  void _onRemoveEspTap(ClasseItem value) {
    _classes.remove(value.id);
    _setState();
  }


  void _onDateTap() async {
    final res = await Popup(context).dateTime(_dataController.text);

    if (res == null) return;

    _dataController.text = Formats.data(res);
  }

  void _setInProgress(bool b) {
    _inProgress = b;
    _setState();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}