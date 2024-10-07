import 'dart:io';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class SgcMembroPage extends StatefulWidget {
  final Membro membro;
  final bool readOnly;
  final bool showAppBar;
  const SgcMembroPage({
    super.key,
    required this.membro,
    this.readOnly = true,
    this.showAppBar = true,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcMembroPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  //region variaveis

  final _log = const Log('SgcMembroPage');

  late Membro _membro = widget.membro;
  bool get readOnly => widget.readOnly;
  bool get showAppBar => widget.showAppBar;

  late final TabController _tabController = TabController(length: 2, vsync: this);

  FichaMedica get _fichaMedica => _membro.fichaMedica;

  final _dataController = MaskedTextController(mask: Masks.date);

  final _dadosScrollController = ScrollController();
  final _fichaScrollController = ScrollController();
  final _formDadosKey = GlobalKey<FormState>();
  final _formFichaKey = GlobalKey<FormState>();

  bool _dadosPreenchidos = false;
  bool _inProgress = false;

  String? _nomeTemp;
  String? _cpfTemp;

  String? _erroSexo;

  Future? _future;

  /// Armazena fotos recortadas pra excluir mais tarde
  final List<String> _tempImages = [];
  File? _image;

  @override
  bool get wantKeepAlive => true;
  bool get isNovo => _membro.codUsuario == 0;

  final _formKeys = Util.sgcFormKeys;

  //endregion

  //region widgets

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: showAppBar ? SgcAppBar(
        title: const Text('Membro'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (i) {
            if (!_dadosPreenchidos) {
              _tabController.index = 0;
              Log.snack('Preencha os dados e clique em continuar', isError: true);
            }
            _setState();
          },
          tabs: const [
            Tab(text: 'Dados'),
            Tab(text: 'Ficha médica'),
          ],
        ),
      ) : null,
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          try {
            return IndexedStack(
              index: _tabController.index,
              children: [
                DadosPage(
                  controller: _dadosScrollController,
                  formKey: _formDadosKey,
                  formKeys: _formKeys,
                  erroSexo: _erroSexo,
                  dataController: _dataController,
                  membro: _membro,
                  image: _image,
                  showSaveButton: !_inProgress,
                  onAlterarFotoTap: _onAlterarFotoTap,
                  onBatizadoChanged: (value) => setState(() => _membro.batizado = value!),
                  onDataTap: _onDataTap,
                  onEstadoChanged: _onEstadoChanged,
                  // onSaveFotoTap: _onSaveFotoTap,
                  onSexoChanged: (value) => setState(() => _membro.sexo = value!),
                ),

                FichaMedicaPage(
                  controller: _fichaScrollController,
                  membro: _membro,
                  formKey: _formFichaKey,
                  formKeys: _formKeys,
                  onChanged: _setState,
                ),
              ],
            );
          } catch(e) {
            return Center(
              child: Text(e.toString()),
            );
          }
        },
      ),
      floatingActionButton: _floatingButton(),
    );
  }

  Widget? _floatingButton() {
    if (!showAppBar) return null;

    if (_inProgress) return const CircularProgressIndicator();

    return FloatingActionButton.extended(
      onPressed: _onSaveTap,
      label: Text(_dadosPreenchidos ? 'Salvar' : 'Continuar'),
    );
  }

  //endregion

  //region metodos

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

    if (_membro.codUsuario != 0) {
      _dadosPreenchidos = true;

      _nomeTemp = _membro.nomeUsuario;
      _cpfTemp = _membro.cpf;
    }

    _future = _init();
  }


  Future<void> _init() async {
    if (_membro.codUsuario == 0) return;

    _dataController.text = _membro.dtNascimento;

    if (_membro.fichaMedica.codFicha != 0) return;

    try {
      final res = await Future.wait([
        SgcProvider.i.getMembro(_membro.codUsuario),
        SgcProvider.i.getFichaMedica(_membro.codUsuario),
      ]);

      _membro = res[0] as Membro;
      _membro.fichaMedica = res[1] as FichaMedica;
      _dataController.text = _membro.dtNascimento;
    } catch(e) {
      _log.e('_init', e);
    }
  }

  void _onSaveTap() async {
    if (!_saveDados()) return;
    if (!_saveFicha()) return;

    try {
      _setInProgress(true);

      int codClube = ClubeProvider.i.clube.codigo;
      if (codClube == 0) {
        codClube = await SgcProvider.i.getCodClube();
        if (codClube == 0) throw 'clubeCod == null';

        ClubeProvider.i.setCodigo(codClube);
      }

      final codAutor = FirebaseProvider.i.user.codUsuario;

      Map<String, dynamic> bodyDados = {
        'cod_clube': '$codClube',
        'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
        'cod_autor': codAutor,
        'tel_usuario': '',
        'cod_idioma': '1',
        'seguro': '1',
        'acesso': 'S',
        'Submit': 'Salvar',
        if (_nomeTemp != null)
          'nome_usuario1': _nomeTemp,
        if (_cpfTemp != null)
          'cpf1': _cpfTemp,
        if (_membro.codUsuario == 0)
          'MM_insert': 'form1'
        else
          'MM_update': 'form1',
      };
      Map<String, dynamic> bodyFicha = {
        'cod_autor': codAutor,
        'Submit': 'Confirmar',
        'MM_update': 'form1',
      };

      await _onSaveFotoTap();

      await SgcProvider.i.enviarMembro(_membro, bodyDados,
        ficha: _fichaMedica,
        bodyFicha: bodyFicha,
      );

      if (!MembrosProvider.i.data.containsKey(_membro.id)) {
        FirebaseProvider.i.criarIdentificador(_membro.id);
      }

      await MembrosProvider.i.add(_membro);

      Log.snack('Dados Salvos');
    } catch(e) {
      Log.snack(e.toString(), isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
      _log.e('_onSaveTap', e);
    }

    _setInProgress(false);
  }

  Future<void> _onSaveFotoTap() async {
    if (_image == null) return;

    final body = <String, String>{
      'cod_usuario': '${_membro.codUsuario}',
      'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
      'Submit': 'Salvar',
    };

    await SgcProvider.i.enviarFoto(_membro.codUsuario, await _image!.readAsBytes(), body);
    await FastCachedImageConfig.deleteCachedImage(imageUrl: _membro.foto);

    _image = null;
  }

  bool _saveDados() {
    final form = _formDadosKey.currentState!;

    _erroSexo = null;
    if (_membro.sexo.isEmpty) _erroSexo = 'Selecione o sexo';

    if (_erroSexo != null) {
      _tabController.index = 0;
    }

    _setState();

    if (!form.validate()) {
      _tabController.index = 0;
      _moveScroll();
      return false;
    }
    _moveScroll();
    form.save();

    if ((_membro.idade ?? 0) < 16) {
      if (_membro.cpf.isEmpty && _membro.cpfResp.isEmpty) {
        DialogBox(
          context: context,
          content: const [
            Text('O membro tem menos de 16 anos.'),
            Text('Informe o CPF do membro ou de seu responsável'),
          ],
        ).ok();
        return false;
      }
    }

    if (_membro.cpf.isNotEmpty && _membro.cpfResp.isNotEmpty) {
      _membro.cpfResp = '';
    }

    if (_membro.codFuncao == 53 && _membro.codTipoProf == 0) {
      Popup(context).msg('Selecione a função na área da saúde por favor!');
      return false;
    }

    if (_membro.codTipoProf != 0 && _membro.docProf.isEmpty) {
      Popup(context).msg("Preencha seu documento de profissional na área da saúde por favor!");
      return false;
    }

    if (!_dadosPreenchidos) {
      _dadosPreenchidos = true;
      _tabController.index = 1;
    }

    return true;
  }

  bool _saveFicha() {
    final form = _formFichaKey.currentState!;
    if (!form.validate()) {
      _tabController.index = 1;
      _moveScroll();
      return false;
    }
    _moveScroll();
    form.save();

    if (_fichaMedica.fratura.isEmpty && _fichaMedica.tempoFratura.isNotEmpty) {
      Popup(context).msg("Preencha qual o tipo de fratura");
      // f.fratura.focus();
      return false;
    }
    if (_fichaMedica.fratura.isNotEmpty && _fichaMedica.tempoFratura.isEmpty) {
      Popup(context).msg("Preencha o tempo de imobilização da fratura");
      // f.tempo_fratura.focus();
      return false;
    }

    if (!_fichaMedica.confirmacao) {
      Popup(context).msg('Você precisa confirmar que verificou os dados da ficha');

      _tabController.index = 1;
      return false;
    }

    _fichaMedica.dtConfirmacao = Formats.dataHoraUs(DateTime.now());

    _fichaMedica.codUsuario = _membro.codUsuario;

    return true;
  }

  void _moveScroll() {
    const anim = Duration(milliseconds: 400);

    BuildContext? getContext(String key) {
      return _formKeys[key]?.currentContext;
    }

    void scrollTo(String key) {
      final ctx = getContext(key);
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, duration: anim);
      }
    }

    if (_membro.codFuncao == 0) {
      scrollTo('codFuncao');
      return;
    }

    if (_membro.nomeUsuario.isEmpty) {
      scrollTo('nomeUsuario');
      return;
    }

    if (_dataController.text.isEmpty) {
      scrollTo('dtNascimento');
      return;
    }

    if (Validators.telefone(_membro.celUsuario) != null) {
      scrollTo('celUsuario');
      return;
    }

    if (Validators.email(_membro.emailUsuario) != null) {
      scrollTo('emailUsuario');
      return;
    }

    if (_membro.sexo.isEmpty) {
      scrollTo('sexo');
      return;
    }

    if (_membro.codEstadoCivil == 0) {
      scrollTo('codEstadoCivil');
      return;
    }

    if (_membro.codCamiseta == 0) {
      scrollTo('codCamiseta');
      return;
    }

    if (Validators.cpf(_membro.cpf) != null) {
      scrollTo('cpf');
      return;
    }

    if (_membro.codEstado == 0) {
      scrollTo('codEstado');
      return;
    } else if (_membro.codCidade == 0) {
      scrollTo('codCidade');
      return;
    }

    // if (Validators.cep(_membro.cepUsuario) != null) {
    //   scrollTo('cepUsuario');
    //   return;
    // }

    if (_membro.codTipoProf == 0 && _membro.codFuncao == 53) {
      scrollTo('codTipoProf');
      return;
    }

    if (_membro.codTipoProf != 0 && _membro.docProf.isEmpty) {
      scrollTo('docProf');
      return;
    }


    if (Validators.email(_membro.emailPai) != null) {
      scrollTo('emailPai');
      return;
    }

    if (Validators.email(_membro.emailMae) != null) {
      scrollTo('emailMae');
      return;
    }

    if (Validators.telefone(_membro.telPai) != null) {
      scrollTo('telPai');
      return;
    }

    if (Validators.telefone(_membro.telMae) != null) {
      scrollTo('telMae');
      return;
    }


    if (Validators.email(_membro.emailResponsavel) != null) {
      scrollTo('emailResponsavel');
      return;
    }

    if (Validators.telefone(_membro.telResponsavel) != null) {
      scrollTo('telResponsavel');
      return;
    }

    if (Validators.cpf(_membro.cpfResp) != null) {
      scrollTo('cpfResp');
      return;
    }



    if (_fichaMedica.plano && _fichaMedica.descPlano.isEmpty) {
      scrollTo('descPlano');
      return;
    }

    if (_fichaMedica.codSangue == 0) {
      scrollTo('codSangue');
      return;
    }


    if (_fichaMedica.cardiaco && _fichaMedica.remediosCardiaco.isEmpty) {
      scrollTo('remediosCardiaco');
      return;
    }

    if (_fichaMedica.diabetes && _fichaMedica.remediosDiabetes.isEmpty) {
      scrollTo('remediosDiabetes');
      return;
    }

    if (_fichaMedica.renal && _fichaMedica.remediosRenal.isEmpty) {
      scrollTo('remediosRenal');
      return;
    }

    if (_fichaMedica.mental && _fichaMedica.remediosMental.isEmpty) {
      scrollTo('remediosMental');
      return;
    }


    if (_fichaMedica.fratura.isEmpty && _fichaMedica.tempoFratura.isNotEmpty) {
      scrollTo('fratura');
      return;
    }

    if (_fichaMedica.fratura.isNotEmpty && _fichaMedica.tempoFratura.isEmpty) {
      scrollTo('tempoFratura');
      return;
    }

    if (!_fichaMedica.confirmacao) {
      scrollTo('confirmacao');
      return;
    }

  }


  void _onEstadoChanged(int? value) {
    _membro.codEstado = value!;
    _membro.codCidade = Arrays.cidades[_membro.codEstado]!.keys.first;
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

  void _onDataTap() async {
    if (_membro.dtNascimento.isNotEmpty && !isNovo && _membro.segurado) {
      DialogBox(
        context: context,
        content: const [
          Text('Não é possível alterar a data de nascimento de membros segurados'),
        ],
      ).ok();
      return;
    }

    final res = await Popup(context).dateTime(_dataController.text);

    if (res == null) return;

    _dataController.text = Formats.data(res);
    _membro.dtNascimento = _dataController.text;
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



  //endregion

}

class DadosPage extends StatelessWidget {
  final Membro membro;
  final File? image;
  final String? erroSexo;
  final bool showSaveButton;
  final bool canChangeCargo;
  final ScrollController? controller;
  final MaskedTextController? dataController;
  final GlobalKey<FormState>? formKey;
  final Map<String, GlobalKey> formKeys;
  final void Function(int?)? onEstadoChanged;
  final void Function(String?)? onSexoChanged;
  final void Function(bool?)? onBatizadoChanged;
  final void Function()? onAlterarFotoTap;
  // final void Function()? onSaveFotoTap;
  final void Function()? onDataTap;
  const DadosPage({
    super.key,
    required this.membro,
    this.image,
    this.erroSexo,
    this.showSaveButton = false,
    this.canChangeCargo = true,
    this.controller,
    this.dataController,
    this.formKey,
    required this.formKeys,
    this.onEstadoChanged,
    this.onDataTap,
    this.onAlterarFotoTap,
    // this.onSaveFotoTap,
    this.onSexoChanged,
    this.onBatizadoChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isNovo = membro.codUsuario == 0;

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 80),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    _fotoTile(),

                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: onAlterarFotoTap,
                            child: const Text('Alterar Foto'),
                          ),

                          // if (image != null && showSaveButton)...[
                          //   const SizedBox(width: 5),
                          //
                          //   ElevatedButton(
                          //     onPressed: onSaveFotoTap,
                          //     child: const Text('Salvar Foto'),
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),  // foto

            DropdownButtonFormField(
              key: formKeys['codFuncao'],
              value: membro.codFuncao,
              decoration: const InputDecoration(
                labelText: 'Função',
              ),
              items: Arrays.funcoes.keys.map((key) => DropdownMenuItem(
                value: key,
                child: Text(Arrays.funcoes[key]!),
              )).toList(),
              onChanged: !canChangeCargo ? null : (int? value) => membro.codFuncao = value!,
              validator: Validators.dropDownIntObrigatorio,
            ),  // cod_funcao

            Card(
              child: Column(
                children: [
                  TextFormField(
                    key: formKeys['nomeUsuario'],
                    initialValue: membro.nomeUsuario,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Nome completo',
                    ),
                    validator: Validators.obrigatorio,
                    onChanged: (value) => membro.nomeUsuario = value,
                  ),  // nome_usuario

                  TextFormField(
                    key: formKeys['dtNascimento'],
                    controller: dataController,
                    keyboardType: TextInputType.datetime,
                    inputFormatters: TextType.data.inputFormatters,
                    readOnly: membro.dtNascimento.isNotEmpty && !isNovo && membro.segurado,
                    decoration: InputDecoration(
                      labelText: 'Data de nascimento',
                      suffixIcon: IconButton(
                        tooltip: 'Selecionar',
                        onPressed: onDataTap,
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ),
                    validator: Validators.dataObrigatorio,
                    onChanged: (value) => membro.dtNascimento = value,
                  ),  // dt_nascimento

                  TextFormField(
                    key: formKeys['celUsuario'],
                    initialValue: Formats.formatarTelefone(membro.celUsuario),
                    keyboardType: TextInputType.phone,
                    inputFormatters: TextType.phone.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Telefone',
                    ),
                    validator: Validators.telefone,
                    onChanged: (value) => membro.celUsuario = value,
                  ),  // cel_usuario

                  TextFormField(
                    key: formKeys['emailUsuario'],
                    initialValue: membro.emailUsuario.toLowerCase(),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                    validator: Validators.email,
                    onChanged: (value) => membro.emailUsuario = value,
                  ),  // email_usuario

                  InputDecorator(
                    key: formKeys['sexo'],
                    decoration: InputDecoration(
                      labelText: 'Sexo',
                      errorText: erroSexo,
                    ),
                    child: Row(
                      children: [
                        Expanded(child: RadioListTile(
                          title: const Text('Masculino'),
                          value: 'M',
                          groupValue: membro.sexo,
                          onChanged: onSexoChanged,
                        )),  // M
                        Expanded(child: RadioListTile(
                          title: const Text('Feminino'),
                          value: 'F',
                          groupValue: membro.sexo,
                          onChanged: onSexoChanged,
                        )),  // F
                      ],
                    ),
                  ), // sexo

                  DropdownButtonFormField(
                    key: formKeys['codEstadoCivil'],
                    value: membro.codEstadoCivil,
                    decoration: const InputDecoration(
                      labelText: 'Estado Civil',
                    ),
                    items: Arrays.estadoCivil.keys.map((key) => DropdownMenuItem(
                      value: key,
                      child: Text(Arrays.estadoCivil[key]!),
                    )).toList(),
                    validator: Validators.dropDownIntObrigatorio,
                    onChanged: (value) => membro.codEstadoCivil = value!,
                  ),  // cod_estado_civil

                  DropdownButtonFormField(
                    key: formKeys['codCamiseta'],
                    value: membro.codCamiseta,
                    decoration: const InputDecoration(
                      labelText: 'Tamanho da Camisa',
                    ),
                    items: Arrays.tamanhoCamisa.keys.map((key) => DropdownMenuItem(
                      value: key,
                      child: Text(Arrays.tamanhoCamisa[key]!),
                    )).toList(),
                    validator: Validators.dropDownIntObrigatorio,
                    onChanged: (value) => membro.codCamiseta = value!,
                  ),  // cod_camiseta

                  CheckboxListTile(
                    title: const Text('Batizado'),
                    value: membro.batizado,
                    onChanged: onBatizadoChanged,
                  ),  // batizado

                  CheckboxListTile(
                    title: const Text('Segurado'),
                    value: membro.segurado,
                    onChanged: (value) {
                      /// todo seguro
                      Log.snack('Ainda não pode ser alterado', isError: true);
                    },
                  ),  // assegurado

                ],
              ),
            ),  // dados

            const Divider(),
            Card(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: membro.certidao,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Certidão de nascimento',
                    ),
                    onChanged: (value) => membro.certidao = value,
                  ),  // certidao

                  TextFormField(
                    initialValue: membro.rg,
                    keyboardType: TextInputType.number,
                    inputFormatters: TextType.numero.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'RG',
                    ),
                    onChanged: (value) => membro.rg = value,
                  ),  // rg

                  TextFormField(
                    key: formKeys['cpf'],
                    initialValue: Formats.formatarCpf(membro.cpf),
                    keyboardType: TextInputType.number,
                    inputFormatters: TextType.cpf.inputFormatters,
                    readOnly: membro.cpf.isNotEmpty && !isNovo && CPFValidator.isValid(membro.cpf),
                    decoration: const InputDecoration(
                      labelText: 'CPF',
                    ),
                    validator: Validators.cpf,
                    onChanged: (value) => membro.cpf = Formats.removeMascara(value),
                  ),  // cpf

                  TextFormField(
                    initialValue: membro.orgExp,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Orgão Expedidor',
                    ),
                    onChanged: (value) => membro.orgExp = value,
                  ),  // org_exp
                ],
              ),
            ),  // documentos

            const Divider(),
            Card(
              child: Column(
                children: [
                  DropdownButtonFormField(
                    key: formKeys['codEstado'],
                    value: membro.codEstado,
                    decoration: const InputDecoration(
                      labelText: 'Estado',
                    ),
                    items: Arrays.estado.keys.map((key) => DropdownMenuItem(
                      value: key,
                      child: Text(Arrays.estado[key]!),
                    )).toList(),
                    validator: Validators.dropDownIntObrigatorio,
                    onChanged: onEstadoChanged,
                  ),  // cod_estado

                  if (membro.codEstado > 0)
                    DropdownButtonFormField(
                      key: formKeys['codCidade'],
                      value: membro.codCidade,
                      decoration: const InputDecoration(
                        labelText: 'Cidade',
                      ),
                      items: Arrays.cidades[membro.codEstado]!.keys.map((key) => DropdownMenuItem(
                        value: key,
                        child: Text(Arrays.cidades[membro.codEstado]![key]!),
                      )).toList(),
                      validator: Validators.dropDownIntObrigatorio,
                      onChanged: (value) => membro.codCidade = value!,
                    ),  // cod_cidade

                  TextFormField(
                    key: formKeys['cepUsuario'],
                    initialValue: Formats.formatarCep(membro.cepUsuario),
                    keyboardType: TextInputType.number,
                    inputFormatters: TextType.cep.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Cep',
                    ),
                    onChanged: (value) => membro.cepUsuario = value,
                  ),  // cep_usuario

                  TextFormField(
                    initialValue: membro.endUsuario,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Rua e número',
                    ),
                    onChanged: (value) => membro.endUsuario = value,
                  ),  // end_usuario

                  TextFormField(
                    initialValue: membro.bairroUsuario,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Bairro',
                    ),
                    onChanged: (value) => membro.bairroUsuario = value,
                  ),  // bairro_usuario
                ],
              ),
            ),  // endereço

            const Divider(),
            Card(
              child: Column(
                children: [
                  DropdownButtonFormField(
                    key: formKeys['codTipoProf'],
                    value: membro.codTipoProf,
                    decoration: const InputDecoration(
                      labelText: 'Profissional de saúde',
                    ),
                    items: Arrays.profSaude.keys.map((key) => DropdownMenuItem(
                      value: key,
                      child: Text(Arrays.profSaude[key]!),
                    )).toList(),
                    onChanged: (value) => membro.codTipoProf = value!,
                  ),  // cod_tipo_prof

                  TextFormField(
                    key: formKeys['docProf'],
                    initialValue: membro.docProf,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Documento profissional',
                    ),
                    onChanged: (value) => membro.docProf = value,
                  ),  // doc_prof
                ],
              ),
            ),  // prof saúde

            const Divider(),
            Card(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: membro.nomePai,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Pai',
                    ),
                    onChanged: (value) => membro.nomePai = value,
                  ),  // nome_pai
                  TextFormField(
                    initialValue: membro.nomeMae,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Mãe',
                    ),
                    onChanged: (value) => membro.nomeMae = value,
                  ),  // nome_mae

                  TextFormField(
                    key: formKeys['emailPai'],
                    initialValue: membro.emailPai.toLowerCase(),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Email do Pai',
                    ),
                    validator: Validators.email,
                    onChanged: (value) => membro.emailPai = value,
                  ),  // email_pai
                  TextFormField(
                    key: formKeys['emailMae'],
                    initialValue: membro.emailMae.toLowerCase(),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Email da Mãe',
                    ),
                    validator: Validators.email,
                    onChanged: (value) => membro.emailMae = value,
                  ),  // email_mae

                  TextFormField(
                    key: formKeys['telPai'],
                    initialValue: Formats.formatarTelefone(membro.telPai),
                    keyboardType: TextInputType.phone,
                    inputFormatters: TextType.phone.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Telefone do Pai',
                    ),
                    validator: Validators.telefone,
                    onChanged: (value) => membro.telPai = value,
                  ),  // tel_pai
                  TextFormField(
                    key: formKeys['telMae'],
                    initialValue: Formats.formatarTelefone(membro.telMae),
                    keyboardType: TextInputType.phone,
                    inputFormatters: TextType.phone.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Telefone da Mãe',
                    ),
                    validator: Validators.telefone,
                    onChanged: (value) => membro.telMae = value,
                  ),  // tel_mae
                ],
              ),
            ),  // pai e mãe

            const Divider(),
            Card(
              child: Column(
                children: [
                  const Text('Caso não tenha pai ou mãe, preencha o nome do responsável jurídico'),

                  TextFormField(
                    initialValue: membro.responsavel,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Responsável',
                    ),
                    onChanged: (value) => membro.responsavel = value,
                  ),  // responsavel

                  TextFormField(
                    key: formKeys['emailResponsavel'],
                    initialValue: membro.emailResponsavel.toLowerCase(),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Email do Responsável',
                    ),
                    validator: Validators.email,
                    onChanged: (value) => membro.emailResponsavel = value,
                  ),  // email_responsavel

                  TextFormField(
                    key: formKeys['telResponsavel'],
                    initialValue: Formats.formatarTelefone(membro.telResponsavel),
                    keyboardType: TextInputType.phone,
                    inputFormatters: TextType.phone.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Telefone do Responsável',
                    ),
                    validator: Validators.telefone,
                    onChanged: (value) => membro.telResponsavel = value,
                  ),  // tel_responsavel

                  TextFormField(
                    initialValue: membro.vinculoResponsavel,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Grau de parentesco',
                    ),
                    onChanged: (value) => membro.vinculoResponsavel = value,
                  ),  // vinculo_responsavel

                  TextFormField(
                    key: formKeys['cpfResp'],
                    initialValue: Formats.formatarCpf(membro.cpfResp),
                    keyboardType: TextInputType.number,
                    inputFormatters: TextType.cpf.inputFormatters,
                    readOnly: membro.cpfResp.isNotEmpty && !isNovo && CPFValidator.isValid(membro.cpfResp),
                    decoration: const InputDecoration(
                      labelText: 'CPF do responsável',
                    ),
                    validator: Validators.cpf,
                    onChanged: (value) => membro.cpfResp = Formats.removeMascara(value),
                  ),  // cpf_resp
                ],
              ),
            ),  // responsável

          ],
        ),
      ),
    );
  }

  Widget _fotoTile() {
    if (image != null) {
      return Image.file(File(image!.path),
        fit: BoxFit.cover,
        errorBuilder: errorBuiler,
      );
    }

    return FotoLayout(
      path: membro.foto,
      borderRadius: 0,
      aspectRatio: 1/1.2,
    );
  }

}

class FichaMedicaPage extends StatelessWidget {
  final Membro membro;
  final ScrollController? controller;
  final GlobalKey<FormState>? formKey;
  final Map<String, GlobalKey> formKeys;
  final void Function()? onChanged;
  const FichaMedicaPage({
    super.key,
    required this.membro,
    this.controller,
    this.formKey,
    this.onChanged,
    required this.formKeys,
  });

  FichaMedica get _fichaMedica => membro.fichaMedica;

  @override
  Widget build(BuildContext context) {
    var nome = membro.nomeUsuario;
    if (nome.isEmpty) nome = 'o referido membro';

    var confText = 'Confirmo que todos os dados médicos acima são verdadeiros, ';
    confText += 'e que euverifiquei juntamente com $nome ou com ';
    confText += 'seus responsáveis a veracidade desses fatos.';

    return SingleChildScrollView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 80),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('Tem plano de saúde?'),
              value: _fichaMedica.plano,
              onChanged: (value) {
                _fichaMedica.plano = value!;
                onChanged?.call();
              },
            ),  // plano

            if (_fichaMedica.plano)
              TextFormField(
                key: formKeys['descPlano'],
                initialValue: _fichaMedica.descPlano,
                keyboardType: TextInputType.text,
                inputFormatters: TextType.text.upperCase.inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Nome do plano de saúde',
                ),
                validator: Validators.obrigatorio,
                onChanged: (value) => _fichaMedica.descPlano = value,
              ),  // desc_plano

            TextFormField(
              key: const Key('carteira'),
              initialValue: _fichaMedica.carteira,
              keyboardType: TextInputType.number,
              inputFormatters: TextType.sus.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Cartão SUS',
              ),
              onChanged: (value) => _fichaMedica.carteira = value,
            ),  // carteira sus

            DropdownButtonFormField(
              key: formKeys['codSangue'],
              value: _fichaMedica.codSangue,
              decoration: const InputDecoration(
                labelText: 'Tipo sanguíneo',
              ),
              items: Arrays.tipoSanguineo.keys.map((key) => DropdownMenuItem(
                value: key,
                child: Text(Arrays.tipoSanguineo[key]!),
              )).toList(),
              validator: Validators.dropDownIntObrigatorio,
              onChanged: (value) => _fichaMedica.codSangue = value!,
            ),  // cod_sangue

            //region Checkbox

            CheckboxListTile(
              title: const Text('Já teve catapora?'),
              value: _fichaMedica.catapora,
              onChanged: (value) {
                _fichaMedica.catapora = value!;
                onChanged?.call();
              },
            ),  // catapora

            CheckboxListTile(
              title: const Text('Já teve meningite?'),
              value: _fichaMedica.meningite,
              onChanged: (value) {
                _fichaMedica.meningite = value!;
                onChanged?.call();
              },
            ),  // meningite

            CheckboxListTile(
              title: const Text('Já teve hepatite?'),
              value: _fichaMedica.hepatite,
              onChanged: (value) {
                _fichaMedica.hepatite = value!;
                onChanged?.call();
              },
            ),  // hepatite

            CheckboxListTile(
              title: const Text('Já teve dengue?'),
              value: _fichaMedica.dengue,
              onChanged: (value) {
                _fichaMedica.dengue = value!;
                onChanged?.call();
              },
            ),  // dengue

            CheckboxListTile(
              title: const Text('Já teve pneumonia?'),
              value: _fichaMedica.pneumonia,
              onChanged: (value) {
                _fichaMedica.pneumonia = value!;
                onChanged?.call();
              },
            ),  // pneumonia

            CheckboxListTile(
              title: const Text('Já teve malária?'),
              value: _fichaMedica.malaria,
              onChanged: (value) {
                _fichaMedica.malaria = value!;
                onChanged?.call();
              },
            ),  // malaria

            CheckboxListTile(
              title: const Text('Já teve febre amarela?'),
              value: _fichaMedica.febre,
              onChanged: (value) {
                _fichaMedica.febre = value!;
                onChanged?.call();
              },
            ),  // febre

            CheckboxListTile(
              title: const Text('Já teve H1N1?'),
              value: _fichaMedica.h1n1,
              onChanged: (value) {
                _fichaMedica.h1n1 = value!;
                onChanged?.call();
              },
            ),  // h1n1

            CheckboxListTile(
              title: const Text('Já teve covid-19?'),
              value: _fichaMedica.covid,
              onChanged: (value) {
                _fichaMedica.covid = value!;
                onChanged?.call();
              },
            ),  // covid

            CheckboxListTile(
              title: const Text('Já teve cólera?'),
              value: _fichaMedica.colera,
              onChanged: (value) {
                _fichaMedica.colera = value!;
                onChanged?.call();
              },
            ),  // colera

            CheckboxListTile(
              title: const Text('Já teve rubéola?'),
              value: _fichaMedica.rubeola,
              onChanged: (value) {
                _fichaMedica.rubeola = value!;
                onChanged?.call();
              },
            ),  // rubeola

            CheckboxListTile(
              title: const Text('Já teve sarampo?'),
              value: _fichaMedica.sarampo,
              onChanged: (value) {
                _fichaMedica.sarampo = value!;
                onChanged?.call();
              },
            ),  // sarampo

            CheckboxListTile(
              title: const Text('Já teve tétano?'),
              value: _fichaMedica.tetano,
              onChanged: (value) {
                _fichaMedica.tetano = value!;
                onChanged?.call();
              },
            ),  // tetano

            CheckboxListTile(
              title: const Text('Já teve varíola?'),
              value: _fichaMedica.variola,
              onChanged: (value) {
                _fichaMedica.variola = value!;
                onChanged?.call();
              },
            ),  // variola

            CheckboxListTile(
              title: const Text('Já teve coqueluche?'),
              value: _fichaMedica.coqueluche,
              onChanged: (value) {
                _fichaMedica.coqueluche = value!;
                onChanged?.call();
              },
            ),  // coqueluche

            CheckboxListTile(
              title: const Text('Já teve difteria?'),
              value: _fichaMedica.difteria,
              onChanged: (value) {
                _fichaMedica.difteria = value!;
                onChanged?.call();
              },
            ),  // difteria

            CheckboxListTile(
              title: const Text('Já teve caxumba?'),
              value: _fichaMedica.caxumba,
              onChanged: (value) {
                _fichaMedica.caxumba = value!;
                onChanged?.call();
              },
            ),  // caxumba

            CheckboxListTile(
              title: const Text('Já fez transfusão de sangue?'),
              value: _fichaMedica.sangue,
              onChanged: (value) {
                _fichaMedica.sangue = value!;
                onChanged?.call();
              },
            ),  // sangue

            CheckboxListTile(
              title: const Text('Tem alergia na pele?'),
              value: _fichaMedica.pele,
              onChanged: (value) {
                _fichaMedica.pele = value!;
                onChanged?.call();
              },
            ),  // pele

            CheckboxListTile(
              title: const Text('Tem alergia alimentar?'),
              value: _fichaMedica.alimentar,
              onChanged: (value) {
                _fichaMedica.alimentar = value!;
                onChanged?.call();
              },
            ),  // alimentar

            CheckboxListTile(
              title: const Text('Tem alergia a algum medicamento?'),
              value: _fichaMedica.medicamento,
              onChanged: (value) {
                _fichaMedica.medicamento = value!;
                onChanged?.call();
              },
            ),  // medicamento

            CheckboxListTile(
              title: const Text('Tem rinite?'),
              value: _fichaMedica.renite,
              onChanged: (value) {
                _fichaMedica.renite = value!;
                onChanged?.call();
              },
            ),  // renite

            CheckboxListTile(
              title: const Text('Tem bronquite?'),
              value: _fichaMedica.bronquite,
              onChanged: (value) {
                _fichaMedica.bronquite = value!;
                onChanged?.call();
              },
            ),  // bronquite

            CheckboxListTile(
              title: const Text('Deficiente físico (cadeirante)'),
              value: _fichaMedica.cadeirante,
              onChanged: (value) {
                _fichaMedica.cadeirante = value!;
                onChanged?.call();
              },
            ),  // cadeirante

            CheckboxListTile(
              title: const Text('Deficiente visual'),
              value: _fichaMedica.visual,
              onChanged: (value) {
                _fichaMedica.visual = value!;
                onChanged?.call();
              },
            ),  // visual

            CheckboxListTile(
              title: const Text('Deficiente auditivo'),
              value: _fichaMedica.auditivo,
              onChanged: (value) {
                _fichaMedica.auditivo = value!;
                onChanged?.call();
              },
            ),  // auditivo

            CheckboxListTile(
              title: const Text('Deficiência na fala'),
              value: _fichaMedica.fala,
              onChanged: (value) {
                _fichaMedica.fala = value!;
                onChanged?.call();
              },
            ),  // fala

            //endregion

            const Divider(),

            CheckboxListTile(
              title: const Text('Possui problemas cardíacos'),
              value: _fichaMedica.cardiaco,
              onChanged: (value) {
                _fichaMedica.cardiaco = value!;
                onChanged?.call();
              },
            ),  // cardiaco

            if (_fichaMedica.cardiaco)
              TextFormField(
                key: formKeys['remediosCardiaco'],
                initialValue: _fichaMedica.remediosCardiaco,
                keyboardType: TextInputType.text,
                inputFormatters: TextType.text.upperCase.inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Remédios utilisados',
                ),
                validator: Validators.obrigatorio,
                onChanged: (value) => _fichaMedica.remediosCardiaco = value,
              ),  // remedios_cardiaco

            CheckboxListTile(
              title: const Text('Possui diabetes'),
              value: _fichaMedica.diabetes,
              onChanged: (value) {
                _fichaMedica.diabetes = value!;
                onChanged?.call();
              },
            ),  // diabetes

            if (_fichaMedica.diabetes)
              TextFormField(
                key: formKeys['remediosDiabetes'],
                initialValue: _fichaMedica.remediosDiabetes,
                keyboardType: TextInputType.text,
                inputFormatters: TextType.text.upperCase.inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Remédios utilisados',
                ),
                validator: Validators.obrigatorio,
                onChanged: (value) => _fichaMedica.remediosDiabetes = value,
              ),  // remedios_diabetes

            CheckboxListTile(
              title: const Text('Possui problemas renais'),
              value: _fichaMedica.renal,
              onChanged: (value) {
                _fichaMedica.renal = value!;
                onChanged?.call();
              },
            ),  // renal

            if (_fichaMedica.renal)
              TextFormField(
                key: formKeys['remediosRenal'],
                initialValue: _fichaMedica.remediosRenal,
                keyboardType: TextInputType.text,
                inputFormatters: TextType.text.upperCase.inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Remédios utilisados',
                ),
                validator: Validators.obrigatorio,
                onChanged: (value) => _fichaMedica.remediosRenal = value,
              ),  // remedios_renal

            CheckboxListTile(
              title: const Text('Possui problemas mentais'),
              value: _fichaMedica.mental,
              onChanged: (value) {
                _fichaMedica.mental = value!;
                onChanged?.call();
              },
            ),  // mental

            if (_fichaMedica.mental)
              TextFormField(
                key: formKeys['remediosMental'],
                initialValue: _fichaMedica.remediosMental,
                keyboardType: TextInputType.text,
                inputFormatters: TextType.text.upperCase.inputFormatters,
                decoration: const InputDecoration(
                  labelText: 'Remédios utilisados',
                ),
                validator: Validators.obrigatorio,
                onChanged: (value) => _fichaMedica.remediosMental = value,
              ),  // remedios_mental

            const Divider(),

            //region textForm

            TextFormField(
              key: const Key('problemas'),
              initialValue: _fichaMedica.problemas,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Outros problemas de saúde',
              ),
              onChanged: (value) => _fichaMedica.problemas = value,
            ),  // problemas

            TextFormField(
              key: const Key('remedio'),
              initialValue: _fichaMedica.remedio,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Outros medicamentos',
              ),
              onChanged: (value) => _fichaMedica.remedio = value,
            ),  // remedio

            TextFormField(
              key: const Key('recente'),
              initialValue: _fichaMedica.recente,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Problemas de saúde recente',
              ),
              onChanged: (value) => _fichaMedica.recente = value,
            ),  // recente

            TextFormField(
              key: const Key('recenteRemedio'),
              initialValue: _fichaMedica.recenteRemedio,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Medicamentos usados este ano',
              ),
              onChanged: (value) => _fichaMedica.recenteRemedio = value,
            ),  // recente_remedio

            TextFormField(
              key: const Key('alergia'),
              initialValue: _fichaMedica.alergia,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alergias',
              ),
              onChanged: (value) => _fichaMedica.alergia = value,
            ),  // alergia

            TextFormField(
              key: const Key('alergiaRemedio'),
              initialValue: _fichaMedica.alergiaRemedio,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Remédios utilizados para alergias',
              ),
              onChanged: (value) => _fichaMedica.alergiaRemedio = value,
            ),  // alergia_remedio

            TextFormField(
              key: const Key('ferimento'),
              initialValue: _fichaMedica.ferimento,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Ferimento grave recente',
              ),
              onChanged: (value) => _fichaMedica.ferimento = value,
            ),  // ferimento

            TextFormField(
              key: const Key('fratura'),
              initialValue: _fichaMedica.fratura,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Fratura recente',
              ),
              onChanged: (value) => _fichaMedica.fratura = value,
            ),  // fratura

            TextFormField(
              key: const Key('tempoFratura'),
              initialValue: _fichaMedica.tempoFratura,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Tempo imobilizado',
              ),
              onChanged: (value) => _fichaMedica.tempoFratura = value,
            ),  // tempo_fratura

            TextFormField(
              key: const Key('cirurgia'),
              initialValue: _fichaMedica.cirurgia,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Cirurgias que já fez',
              ),
              onChanged: (value) => _fichaMedica.cirurgia = value,
            ),  // cirurgia

            TextFormField(
              key: const Key('internacao'),
              initialValue: _fichaMedica.internacao,
              keyboardType: TextInputType.text,
              inputFormatters: TextType.text.upperCase.inputFormatters,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Motivo de internação nos ultimos 5 anos',
              ),
              onChanged: (value) => _fichaMedica.internacao = value,
            ),  // internacao

            //endregion

            CheckboxListTile(
              key: formKeys['confirmacao'],
              title: const Text('Confirmação'),
              subtitle: Text(confText,
                style: const TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              value: _fichaMedica.confirmacao,
              onChanged: (value) {
                _fichaMedica.confirmacao = value!;
                onChanged?.call();
              },
            ),  // confirmacao

          ],
        ),
      ),
    );
  }
}