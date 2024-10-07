import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class SgcEventoPage extends StatefulWidget {
  final Evento evento;
  const SgcEventoPage({super.key, required this.evento});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcEventoPage> {

  Evento get evento => widget.evento;

  bool get isNovo => evento.codAgenda == 0;

  final _formKey = GlobalKey<FormState>();

  late final MaskedTextController _cDateInicio = MaskedTextController(
    mask: Masks.date,
    text: Formats.convertData(evento.dtAgenda),
  );

  late final MaskedTextController _cDateFim = MaskedTextController(
    mask: Masks.date,
    text: evento.dtAgendaFim,
  );

  late final MaskedTextController _cDateLembrete = MaskedTextController(
    mask: Masks.date,
    text: evento.dtLembrete,
  );

  bool _variosDias = false;
  bool _inProgress = false;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Evento'),
        actions: [
          if (!isNovo)
            IconButton(
              tooltip: 'Remover',
              onPressed: _onDeleteTap,
              icon: const Icon(Icons.delete_forever),
            ),

          const SizedBox(width: 10),
        ],
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField(
                    value: evento.codTipoAgenda,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Atividade ou Evento',
                    ),
                    items: Arrays.tipoEvento.keys.map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(Arrays.tipoEvento[e]!),
                    )).toList(),
                    onChanged: isNovo ? (_) {} : null,
                    validator: Validators.dropDownIntObrigatorio,
                    onSaved: (value) => evento.codTipoAgenda = value!,
                  ),  // tipo

                  TextFormField(
                    initialValue: evento.nomeAgenda,
                    keyboardType: TextInputType.name,
                    inputFormatters: TextType.name.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Titulo',
                    ),
                    validator: Validators.obrigatorio,
                    onSaved: (value) => evento.nomeAgenda = value!,
                  ),  // titulo

                  SwitchListTile(
                    title: const Text('Vários dias'),
                    subtitle: const Text('Vários dias de evento'),
                    value: _variosDias,
                    onChanged: _onOnlyOneDayChanged,
                  ),  // receber email

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cDateInicio,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: TextType.data.inputFormatters,
                          decoration: InputDecoration(
                            labelText: 'Data',
                            suffixIcon: IconButton(
                              tooltip: 'Selecionar data',
                              onPressed: _onDateInicioTap,
                              icon: const Icon(Icons.calendar_month),
                            ),
                          ),
                          validator: Validators.dataObrigatorio,
                          onSaved: (value) => evento.dtAgenda = value!,
                        ),
                      ),  // dt inicio

                      if (_variosDias)
                        Expanded(
                          child: TextFormField(
                            controller: _cDateFim,
                            keyboardType: TextInputType.datetime,
                            inputFormatters: TextType.data.inputFormatters,
                            decoration: InputDecoration(
                              labelText: 'Término',
                              suffixIcon: IconButton(
                                tooltip: 'Selecionar data',
                                onPressed: _onDateFimTap,
                                icon: const Icon(Icons.calendar_month),
                              ),
                            ),
                            validator: (value) {
                              final res = Validators.dataObrigatorio(value);
                              if (res != null) return res;

                              final dIicio = Formats.stringToDateTime(_cDateInicio.text);
                              final dfim = Formats.stringToDateTime(value);

                              if (dIicio == null) return null;
                              if (dfim == null) return 'Data inválida';

                              if (dfim.compareTo(dIicio) < 0) {
                                return 'Data mínima é ${_cDateInicio.text}';
                              }
                              return null;
                            },
                            onSaved: (value) => evento.dtAgendaFim = value!,
                          ),
                        ),  // dt termino
                    ],
                  ),  // datas

                  TextFormField(
                    maxLines: 3,
                    initialValue: evento.descAgenda,
                    keyboardType: TextInputType.text,
                    inputFormatters: TextType.text.upperCase.inputFormatters,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                    ),
                    onSaved: (value) => evento.descAgenda = value!,
                  ),  // descrição

                  SwitchListTile(
                    title: const Text('Receber email de lembrete'),
                    value: evento.opcao,
                    onChanged: _onReceberEmailChanged,
                  ),  // receber email

                  if (evento.opcao)...[
                    TextFormField(
                      controller: _cDateLembrete,
                      keyboardType: TextInputType.datetime,
                      inputFormatters: TextType.data.inputFormatters,
                      decoration: InputDecoration(
                        labelText: 'Data',
                        suffixIcon: IconButton(
                          tooltip: 'Selecionar data',
                          onPressed: _onDateLembreteTap,
                          icon: const Icon(Icons.calendar_month),
                        ),
                      ),
                      validator: (value) {
                        final res = Validators.dataObrigatorio(value);
                        if (res != null) return res;

                        if (value!.compareTo(_cDateFim.text) > 0) {
                          return 'Data máxima é ${_cDateFim.text}';
                        }
                        return null;
                      },
                      onSaved: (value) => evento.dtLembrete = value!,
                    ),  // data

                    TextFormField(
                      initialValue: evento.emailLembrete,
                      keyboardType: TextInputType.emailAddress,
                      inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      onSaved: (value) => evento.emailLembrete = value!,
                      validator: Validators.emailObrigatorio,
                    ),  // email

                    TextFormField(
                      maxLines: 2,
                      initialValue: evento.txtLembrete,
                      keyboardType: TextInputType.text,
                      inputFormatters: TextType.text.upperCase.inputFormatters,
                      decoration: const InputDecoration(
                        labelText: 'Lembrete',
                      ),
                      onSaved: (value) => evento.txtLembrete = value!,
                    ),  // lembrete
                  ],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() :
      FloatingActionButton.extended(
        onPressed: _onSaveTap,
        label: const Text('Salvar'),
      ),
    );
  }

  Future<void> _init() async {
    _variosDias = evento.variosDias;

    if (isNovo) return;

    final data = evento.from!;
    final dia = data.day;
    final mes = data.month;
    final ano = data.year;

    final cod = evento.codAgenda;
    final tipo = evento.codTipoAgenda;

    final ev = await SgcProvider.i.getEvento(cod, dia, mes, ano, tipo);
    if (ev == null) return;

    evento.descAgenda = ev.descAgenda;
    evento.dtLembrete = ev.dtLembrete;
    evento.emailLembrete = ev.emailLembrete;
    evento.txtLembrete = ev.txtLembrete;
    evento.opcao = ev.opcao;

    if (evento.descAgenda == 'Sem descrição') {
      evento.descAgenda = '';
    }
    _setState();
  }

  void _onSaveTap() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    if (evento.descAgenda.isEmpty) {
      evento.descAgenda = 'Sem descrição';
    }

    if (!evento.opcao) {
      evento.dtLembrete = _cDateInicio.text;
      evento.emailLembrete = '';
      evento.txtLembrete = '';
    }

    if (!_variosDias) {
      evento.dtAgendaFim = _cDateInicio.text;
    }

    _setInProgress(true);

    var codClube = ClubeProvider.i.clube.codigo;
    if (codClube == 0) {
      codClube = await SgcProvider.i.getCodClube();
      await ClubeProvider.i.setCodigo(codClube);
    }

    Map<String, String> body = {
      'cod_clube': '$codClube',
      'cod_usuario': '${FirebaseProvider.i.user.codUsuario}',
      'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
      'Submit': 'Salvar',
      'MM_insert': 'form1',
    };

    try {
      final cod = await SgcProvider.i.enviarEvento(evento, body);

      if (cod == null) throw 'codigo do evento igual a null';
      evento.codAgenda = cod;
      await AgendaProvider.i.add(evento);

      Log.snack('Dados enviados');
      if (mounted) Navigator.pop(context, true);
    } catch(e) {
      Log.snack('Erro ao enviar os dados', isError: true, actionClick: !mounted ? null : () {
        Popup(context).errorDetalhes(e);
      });
    }

    _setInProgress(false);
  }

  void _onDeleteTap() async {
    final res = await Popup(context).delete();
    if (!res) return;

    _setInProgress(true);

    try {
      final date = evento.from!;
      final dia = date.day;
      final mes = date.month;
      final ano = date.year;

      await Future.wait([
        SgcProvider.i.removeEvento(evento.codAgenda, dia, mes, ano),
        AgendaProvider.i.remove(evento),
      ]);

      Log.snack('Evento removido');
      if (mounted) Navigator.pop(context, true);
    } catch(e) {
      Log.snack('Erro ao realizar ação', isError: true);
    }

    _setInProgress(false);
  }

  void _onReceberEmailChanged(bool value) {
    evento.opcao = value;
    _setState();
  }

  void _onOnlyOneDayChanged(bool value) {
    _variosDias = value;
    _setState();
  }


  void _onDateInicioTap() async {
    var date = _cDateInicio.text;
    if  (date.isEmpty) date = DateTime.now().toString();

    final res = await Popup(context).dateTime(date,
      max: _variosDias ? _cDateFim.text : '12/12/${DateTime.now().year + 5}',
    );

    if (res == null) return;

    final temp = Formats.data(res);
    _cDateInicio.text = temp;
    evento.dtAgenda = temp;

    if (_cDateFim.text.isEmpty || evento.dtAgenda.compareTo(_cDateFim.text) > 0) {
      _cDateFim.text = temp;
      evento.dtAgendaFim = temp;
    }
  }

  void _onDateFimTap() async {
    final res = await Popup(context).dateTime(_cDateFim.text,
      min: _cDateInicio.text,
      max: '12/12/${DateTime.now().year + 5}',
    );

    if (res == null || !mounted) return;

    final temp = Formats.data(res);

    _cDateFim.text = temp;
    evento.dtAgendaFim = temp;
  }

  void _onDateLembreteTap() async {
    final res = await Popup(context).dateTime(_cDateLembrete.text, max: _cDateFim.text);

    if (res == null || !mounted) return;

    final datteTemp = Formats.data(res);

    if (datteTemp.compareTo(_cDateFim.text) > 0) {
      DialogBox(
        context: context,
        content: const [
          Text('A data do lembrete não pode ser maior que a data de término'),
        ],
      ).ok();
      return;
    }

    _cDateLembrete.text = datteTemp;
    evento.dtLembrete = datteTemp;
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