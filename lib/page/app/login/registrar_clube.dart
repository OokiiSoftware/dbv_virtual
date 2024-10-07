import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class RegistrarClubePage extends StatefulWidget {
  const RegistrarClubePage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<RegistrarClubePage> {

  final _log = const Log('RegistrarClubePage');

  final _fireProv = FirebaseProvider.i;

  final _importProgress = <String, bool>{
    'Membros': false,
    'Identificadores': false,
    'Agenda': false,
    'Registro completo': false,
  };

  late Profile _profile;
  late Clube _clube;

  bool _clubeRegistrado = false;
  bool _importandoDados = false;
  bool _completo = false;

  int _agendaMesImportado = 0;

  Future? _future;

  @override
  void initState() {
    super.initState();
    _future = _init();
  }

  @override
  Widget build(BuildContext context) {
    // _resetProgress();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Clube'),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Obtendo dados do clube'),
                  SizedBox(height: 10),
                  LinearProgressIndicator(),
                ],
              ),
            );
          }

          const styleBody = TextStyle(fontSize: 16);

          if (_clubeRegistrado) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Seu clube foi registrado',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('Importando dados',
                    style: styleBody,
                  ),

                  Text('Não saia do App até o processo ser concluido.',
                    style: styleBody.copyWith(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  if (_importandoDados)...[
                    if (!_completo)
                      const LinearProgressIndicator(),

                    for(var key in _importProgress.keys)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: [
                              Icon(_importProgress[key]! ? Icons.check_circle : Icons.circle_outlined,
                                color: _importProgress[key]! ? Colors.green : null,
                              ),
                              const SizedBox(width: 10),
                              Text(key),
                            ],
                          ),
                        ),
                      ),

                    if (_agendaMesImportado > 0)
                      Text('Importando agenda: ${Formats.intToMes(_agendaMesImportado)}'),

                    const SizedBox(height: 20),

                    if (_completo)
                      SizedBox(
                        height: 40,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onCompleteTap,
                          child: const Text('Concluir'),
                        ),
                      ),
                  ] else...[
                    const SizedBox(height: 20),

                    const Text('Agora vamos importar os dados do seu clube',
                      style: styleBody,
                    ),
                    const Divider(height: 2),

                    const Text('Essa ação pode demorar um pouco dependendo de sua conexão.',
                      style: styleBody,
                    ),
                    const Divider(height: 2),

                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onImportTap,
                        child: const Text('Importar'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }

          return ClubeEditPage(
            readOnly: false,
            onRegistro: _onRegistro,
            clube: _clube,
          );
        },
      ),
    );
  }

  Future<void> _init() async {
    _profile = CvProvider.i.getProfile(_fireProv.codUser)!;

    _clube = Clube(
      nome: _profile.dados[0],
      regiao: _profile.dados[1],
    );
  }

  Future<void> _onRegistro(Clube clube) async {
    _fireProv.setClubeId(clube.id);

    await _fireProv.criarIdentificador('_${_fireProv.codUser}');
    _fireProv.user = _profile.user;

    _clubeRegistrado = true;
    _setState();
  }

  void _onImportTap() async {
    _importandoDados = true;
    _setState();

    try {
      final membros = await SgcProvider.i.getMembrosList();
      if (!_importProgress['Membros']!) {
        await MembrosProvider.i.addAll(membros);

        _importProgress['Membros'] = true;
        _setState();
      }

      if (!_importProgress['Identificadores']!) {
        final ids = membros.map((e) => e.id).toList();
        await _fireProv.criarIdentificadores(ids);

        _importProgress['Identificadores'] = true;
        _setState();
      }

      if (!_importProgress['Agenda']!) {
        final ano = DateTime.now().year;
        final eventos = await SgcProvider.i.getAgenda(ano, onProgress: _onAgendaProgress);
        await AgendaProvider.i.addAll(eventos, );

        _importProgress['Agenda'] = true;
        _agendaMesImportado = 0;
      }

      // delete loginKey

      _importProgress['Registro completo'] = true;
      _completo = true;
    } catch(e) {
      _importandoDados = false;
      _log.e('_onImportTap', e);
      Log.snack('Ocorreu um erro ao importar os dados', isError: true, actionClick: () {
        Popup(context).errorDetalhes(e);
      });
    }

    _setState();
  }

  void _onAgendaProgress(int mes) {
    _agendaMesImportado = mes;
    _setState();
  }

  // ignore: unused_element
  void _resetProgress() {
    _completo = false;
    _importandoDados = false;
    _importProgress.addAll({
      'Membros': false,
      'Identificadores': false,
      'Agenda': false,
      'Registro completo': false,
    });
  }

  void _onCompleteTap() {
    _fireProv.registroCompleto();
  }

  void _setState() {
    if (mounted) {
      setState(() {});
    }
  }
}