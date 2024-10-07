import 'dart:io';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../model/model.dart';
import '../../service/firebase/firebase_database.dart';
import '../../util/util.dart';
import '../../res/res.dart';
import '../page.dart';

class PerfilPage extends StatefulWidget {
  final Membro membro;
  const PerfilPage({super.key, required this.membro});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<PerfilPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  TabController? _tabController;

  Membro get user => widget.membro;
  bool get meuPerfil => user.id == FirebaseProvider.i.user.id;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    if (meuPerfil) {
      _tabController = TabController(
        length: 3,
        vsync: this,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          if (meuPerfil)
            IconButton(
              tooltip: 'Logout',
              onPressed: _onLogoutTap,
              icon: const Icon(Icons.logout_outlined),
            ),
          const SizedBox(width: 10),
        ],
        bottom: meuPerfil ? TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          onTap: (i) => _setState(),
          tabs: const [
            Tab(text: 'Cartão Virtual'),
            Tab(text: 'Cadastro'),
            Tab(text: 'Especialidades'),
          ],
        ) : null,
      ),
      body: IndexedStack(
        index: _tabController?.index ?? 0,
        children: [
          PerfilSubPage(membro: user),
          if (meuPerfil)...[
            CadastroSubPage(membro: user),
            EspecialidadesSubPage(membro: user),
          ],
        ],
      ),
    );
  }

  void _onLogoutTap() async {
    final res = await DialogBox(
      context: context,
      title: 'Sair',
      content: [
        const Text('Deseja sair de sua conta?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    await AppProvider.logout();
    if (mounted) Navigator.pop(context);
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}

class PerfilSubPage extends StatefulWidget {
  final Membro membro;
  const PerfilSubPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _StatePerf();
}
class _StatePerf extends State<PerfilSubPage> {

  final _log = const Log('PerfilSubPage');

  Membro get user => widget.membro;
  Profile get _profile => _cvProvider.getProfile(user.codUsuario) ?? Profile();

  List<List<String>> get _classesConcluidas => _profile.classesConcluidas;
  List<List<String>> get _especialiades => _profile.especialiades;
  List<List<String>> get _historico => _profile.historico;
  List<List<String>> get _eventos => _profile.eventos;
  List<String> get _profileDados => _profile.dados;
  List<Classe> get _classes => _profile.classes.values.toList();

  bool get meuPerfil => user.id == FirebaseProvider.i.user.id;

  final _dataController = MaskedTextController(mask: Masks.date);

  CvProvider _cvProvider = CvProvider.i;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    _cvProvider = context.watch<CvProvider>();

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: _cvBody(),
    );
  }

  Widget _cvBody() {
    const classTetStyle = TextStyle(
      fontWeight: FontWeight.w600,
      shadows: [
        BoxShadow(
          color: Colors.white,
          blurRadius: 2,
        ),
      ],
    );

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          titleSpacing: 60,
          expandedHeight: 400.0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(user.nomeUsuario,
                maxLines: 2,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  shadows: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            background: user.codUsuario == 0 ? const Icon(Icons.person,
              size: 120,
            ) : FotoLayout(
              path: user.foto,
              borderRadius: 0,
              erroIcon: const Icon(Icons.person,
                size: 120,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LinearProgressIndicator();
              }

              Widget bloco(Widget child) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: .5,
                      )
                    ],
                  ),
                  child: child,
                );
              }

              Widget bloclAll(List<List<String>> values, String title) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text('$title (${values.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    for(var e in values)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: bloco(Row(
                          children: [
                            Expanded(child: Text(e[0])),
                            Text(e[1]),
                          ],
                        )),
                      ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var linha in _classes)
                      Builder(
                        builder: (context) {
                          bool noLink = linha.url.isEmpty;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                stops: [
                                  (linha.percent / 100), (linha.percent / 100) + 0.03
                                ],
                                colors: [
                                  Tema.i.primaryColor,
                                  Colors.white,
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: noLink ? null : () => _onClasseTap(linha),
                              child: Container(
                                height: 50,
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                margin: const EdgeInsets.only(bottom: 1),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(linha.name,
                                      style: classTetStyle,
                                    )),
                                    SizedBox(
                                      width: 60,
                                      child: Text('${linha.items}',
                                        style: classTetStyle,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 60,
                                      child: Text('${linha.percent}%',
                                        style: classTetStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Text(user.cargo),
                            subtitle: Text('${user.dtNascimento} - ${user.idade ?? '?'} anos'),
                          ),

                          for(var p in _profileDados)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(p),
                            ),

                          if (_classesConcluidas.isNotEmpty)
                            bloclAll(_classesConcluidas, 'Classes concluidas'),

                          if (_especialiades.isNotEmpty)
                            bloclAll(_especialiades, 'Especialidades'),

                          if (_eventos.isNotEmpty)
                            bloclAll(_eventos, 'Eventos'),

                          if (_historico.isNotEmpty)
                            bloclAll(_historico, 'Histórico'),

                          if (user.endereco.isNotEmpty)...[
                            const Divider(),

                            ListTile(
                              title: Text(user.endereco,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                              subtitle: const Text('Endereço',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Future<void> _init() async {
    _dataController.text = user.dtNascimento;

    await Future.delayed(const Duration(milliseconds: 150));
    _cvProvider.loadLocal();

    await _cvProvider.loadProfile(user.codUsuario);
  }

  Future<void> _loadProfile([bool forceRefresh = true]) async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    try {
      await _cvProvider.loadProfile(
          user.codUsuario, forceRefresh: forceRefresh);
    } catch(e) {
      Log.snack('Erro ao obter dados', isError: true);
      _log.e('_loadProfile', e);
    }
  }


  void _onClasseTap(Classe classe) {
    Navigate.push(context, ClassePage2(
      membro: user,
      classe: classe,
    ));
  }

}

class CadastroSubPage extends StatefulWidget {
  final Membro membro;
  const CadastroSubPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _StateCad();
}
class _StateCad extends State<CadastroSubPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  final _log = const Log('CadastroSubPage');

  Membro get user => widget.membro;
  bool get meuPerfil => user.id == FirebaseProvider.i.user.id;

  final _dataController = MaskedTextController(mask: Masks.date);

  /// Armazena fotos recortadas pra excluir mais tarde
  final List<String> _tempImages = [];

  final _dadosScrollController = ScrollController();
  final _fichaScrollController = ScrollController();

  final _formDadosKey = GlobalKey<FormState>();
  final _formFichaKey = GlobalKey<FormState>();
  final _formKeys = Util.sgcFormKeys;

  bool _inProgress = false;

  File? _image;

  late final _tabController = TabController(length: 2, vsync: this);

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
    for (var path in _tempImages) {
      try {
        File(path).delete();
      } catch(e) {
        continue;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _dataController.text = user.dtNascimento;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (i) => _setState(),
          tabs: const [
            Tab(text: 'Dados'),
            Tab(text: 'Ficha médica'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tabController.index,
        children: [
          DadosPage(
            controller: _dadosScrollController,
            formKey: _formDadosKey,
            formKeys: _formKeys,
            dataController: _dataController,
            membro: user,
            image: _image,
            showSaveButton: !_inProgress,
            canChangeCargo: false,
            onAlterarFotoTap: _onAlterarFotoTap,
            onEstadoChanged: _onEstadoChanged,
            // onSaveFotoTap: _onSaveFotoTap,
            onBatizadoChanged: (value) => setState(() => user.batizado = value!),
            onSexoChanged: (value) => setState(() => user.sexo = value!),
          ),

          FichaMedicaPage(
            controller: _fichaScrollController,
            membro: user,
            formKey: _formFichaKey,
            formKeys: _formKeys,
            onChanged: _setState,
          ),
        ],
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  Widget? _floatingButton() {
    if (_inProgress) return const CircularProgressIndicator();

    return FloatingActionButton.extended(
      onPressed: _onSaveTap,
      label: const Text('Enviar Alterações'),
    );
  }


  void _onSaveTap() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    await DialogBox(
      context: context,
      title: 'Informativo',
      content: const [
        Text('As alterações enviadas passarão pela avaliação do Diretor ou Secretário do clube.'),
        Text('Se aprovado serão enviadas ao SGC'),
      ],
    ).ok();

    _setInProgress(true);
    try {
      if (_image != null) {
        final res = await FirebaseProvider.i.uploadFile([
          ChildKeys.clubes,
          FirebaseProvider.i.clubeId,
          ChildKeys.images,
          '${user.codUsuario}.jpg'
        ], await _image!.readAsBytes());

        user.fotoTemp = res;
      }

      await EditMembrosProvider.i.add(user);

      _image = null;
      Log.snack('Dados enviados');
      if (mounted) {
        DialogBox(
          context: context,
          content: const [
            Text('Seus dados foram enviados, aguarde a aprovação do Diretor ou Secretário do clube'),
          ],
        ).ok();
      } else {
        Log.snack('Dados enviados');
      }
    } catch(e) {
      _log.e('_onSaveTap', e);
      Log.snack('Erro ao enviar os dados', isError: true);
    }
    _setInProgress(false);
  }

  void _onEstadoChanged(int? value) {
    user.codEstado = value!;
    user.codCidade = Arrays.cidades[user.codEstado]!.keys.first;
    _setState();
  }

  void _onAlterarFotoTap() async {
    final picker = ImagePicker();
    final res = await picker.pickImage(source: ImageSource.gallery);
    if (res == null || !mounted) return;

    final tempName = randomString();
    final tempFile = StorageProvider.i.file(['$tempName.jpg']);

    final filePath = await Navigate.push(context, CropImagePage(
      ratio: 1/1,
      inPath: res.path,
      outPath: tempFile.path,
      canChangeRadio: false,
    ));

    if (filePath is! String) return;

    _tempImages.add(tempFile.path);

    _image = File(filePath);
    _setState();
  }

  /*Future<void> _onSaveFotoTap() async {
    _setInProgress(true);

    try {
      final res = await FirebaseProvider.i.uploadFile([
        ChildKeys.clubes,
        FirebaseProvider.i.clubeId,
        ChildKeys.images,
        '${user.codUsuario}.jpg'
      ], await _image!.readAsBytes());

      user.fotoTemp = res;
      await EditMembrosProvider.i.add(user);

      _image = null;
      if (mounted) {
        DialogBox(
          context: context,
          content: const [
            Text('Sua foto foi enviada, aguarde a aprovação do Diretor ou Secretário do clube'),
          ],
        ).ok();
      } else {
        Log.snack('Foto enviada');
      }
    } catch(e) {
      _log.e('_onSaveFotoTap', e);
      Log.snack('Erro ao enviar imagem', isError: true);
    }
    _setInProgress(false);
  }*/


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

class EspecialidadesSubPage extends StatefulWidget {
  final Membro membro;
  const EspecialidadesSubPage({
    super.key,
    required this.membro,
  });

  @override
  State<StatefulWidget> createState() => _StateEsp();
}
class _StateEsp extends State<EspecialidadesSubPage> {

  final _log = const Log('EspecialidadesSubPage');

  Membro get user => widget.membro;

  final _editEspeProvider = EditEspecialidadesProvider.i;

  final _cInstrutor = TextEditingController();
  final _cData = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _focusInsrutor = FocusNode();
  final _focusData = FocusNode();

  static final EspecialidadeSolicitacao _espsLocais = EspecialidadeSolicitacao();

  EspecialidadeSolicitacao? get _espsSolicitados => _editEspeProvider.data[user.id];

  bool _inProgress = false;

  final _dados = EspSolDados();

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    final listLocal = _espsLocais.especialidades.values.toList();
    final listColicitado = _espsSolicitados?.especialidades.values.toList();

    bool ahSelecionados = listColicitado?.where((e) => e.selected).isNotEmpty ?? false;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        body: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 70),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cInstrutor,
                        focusNode: _focusInsrutor,
                        keyboardType: TextInputType.name,
                        inputFormatters: TextType.name.upperCase.inputFormatters,
                        decoration: const InputDecoration(
                            labelText: 'Nome do Instrutor'
                        ),
                        validator: Validators.obrigatorio,
                        onSaved: (value) => _dados.instrutor = value!,
                      ),
                      TextFormField(
                        controller: _cData,
                        focusNode: _focusData,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: TextType.data.inputFormatters,
                        decoration: InputDecoration(
                          labelText: 'Data de conclusão',
                          suffixIcon: IconButton(
                            tooltip: 'Selecionar',
                            onPressed: _onDataTap,
                            icon: const Icon(Icons.calendar_month),
                          ),
                        ),
                        validator: Validators.dataObrigatorio,
                        onSaved: (value) => _dados.data = value!,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: _onAddEspTap,
                  child: const Text('Adicionar especialidade'),
                ),

                const Divider(),

                if (listLocal.isNotEmpty)...[
                  Column(
                    children: [
                      Container(
                        height: 50,
                        width: double.infinity,
                        alignment: Alignment.center,
                        color: Colors.orange,
                        child: const Text('Não enviados',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listLocal.length,
                            separatorBuilder: (_, i) => const SizedBox(height: 2),
                            itemBuilder: (context, i) {
                              final item = listLocal[i];

                              return EspecialidadeTile(
                                key: ValueKey(item),
                                especialidade: item,
                                dense: true,
                                trailing: IconButton(
                                  tooltip: 'Remover',
                                  onPressed: () => _onRemoveLocalTap(item),
                                  icon: const Icon(Icons.delete_forever),
                                ),
                              );
                            },
                          ),

                          Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: _onEnviarTap,
                              title: const Text('Enviar Especialidades'),
                              leading: const Icon(Icons.upload),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),
                ],  // não enviados

                if (listColicitado == null || listColicitado.isEmpty)...[
                  const ListTile(
                    title: Text('Sem solicitações para especialidades pendentes'),
                    leading: Icon(Icons.egg_alt),
                  ),
                ] else...[
                  Column(
                    children: [
                      Container(
                        height: 50,
                        color: Colors.orange,
                        alignment: Alignment.center,
                        child: const Text('Pendente de aprovação',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listColicitado.length,
                            separatorBuilder: (_, i) => const SizedBox(height: 2),
                            itemBuilder: (context, i) {
                              final item = listColicitado[i];

                              return EspecialidadeTile(
                                key: ValueKey(item),
                                especialidade: item,
                                dense: true,
                                onTap: (item) {
                                  item.selected = !item.selected;
                                  _setState();
                                },
                                trailing: Checkbox(
                                  value: item.selected,
                                  onChanged: (value) {
                                    item.selected = value!;
                                    _setState();
                                  },
                                ),
                              );
                            },
                          ),

                          Card(
                            color: Colors.white,
                            child: ListTile(
                              onTap: _onRemoveSelectdTap,
                              title: const Text('Remover selecionados'),
                              leading: Icon(ahSelecionados ? Icons.delete_forever : Icons.egg_alt),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
      ),
    );
  }

  Future<void> _init() async {
    await _editEspeProvider.loadFromId(user.id);
    _preencherDados();
  }

  Future<void> _onRefresh() async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    await _editEspeProvider.refreshFromId(user.id);
    _preencherDados();
    _setState();
  }

  void _onAddEspTap() async {
    _unfocus();

    final items = await Popup(context).especialidade(_espsLocais.especialidades.keys.toList());
    if (items == null) return;

    // if (_espsSolicitados?.especialidades.containsKey(items.id) ?? false) {
    //   return Log.snack('Especialidade já enviada');
    // }

    for (var value in items.values) {
      value.selected = false;
    }

    _espsLocais.especialidades.clear();
    _espsLocais.especialidades.addAll(items);
    _setState();
  }

  void _onRemoveLocalTap(Especialidade value) {
    _unfocus();
    _espsLocais.especialidades.remove(value.id);
    _setState();
  }


  void _onRemoveSelectdTap() async {
    _unfocus();
    final listColicitado = _espsSolicitados!.especialidades.values.toList();

    final selecteds = listColicitado.where((e) => e.selected);

    if (selecteds.isEmpty) {
      Log.snack('Selecione especialidades', isError: true);
      return;
    }

    final res = await DialogBox(
      context: context,
      content: const [
        Text('Deseja remover as especialidades selecionadas?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _setInProgress(true);

    try {
      for (var esp in selecteds) {
        await _editEspeProvider.removeEsp(esp, user.id);
        _espsSolicitados!.especialidades.remove(esp.id);
      }

      if (_espsSolicitados!.especialidades.isEmpty) {
        await _editEspeProvider.removeDados(user.id);
      }

      Log.snack('Dados removidos');
    } catch(e) {
      _log.e('_onRemoveTap', e);
      Log.snack('Erro ao realizar ação', isError: true);
    }

    _setInProgress(false);
  }

  void _onEnviarTap() async {
    _unfocus();

    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    _setInProgress(true);

    try {
      _espsLocais.dados = _dados;
      await _editEspeProvider.add(_espsLocais.copy());

      _espsLocais.especialidades.clear();

      Log.snack('Dados enviados');
    } catch(e) {
      _log.e('_onEnviarTap', e);
      Log.snack('Erro ao enviar os dados', isError: true);
    }

    _setInProgress(false);
  }


  void _preencherDados() {
    _dados.membroId = user.id;
    _dados.instrutor = _espsSolicitados?.dados.instrutor ?? '';
    _dados.data = _espsSolicitados?.dados.data ?? '';

    _cInstrutor.text = _dados.instrutor;
    _cData.text = _dados.data;
  }

  void _onDataTap() async {
    final res = await Popup(context).dateTime(_cData.text);

    if (res == null) return;

    _cData.text = Formats.data(res);
    _espsSolicitados?.dados.data = _cData.text;
  }

  void _unfocus() {
    _focusInsrutor.unfocus();
    _focusData.unfocus();
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