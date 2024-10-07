import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class SeguroChangePage extends StatefulWidget {
  final SeguroRemessa seguro;
  const SeguroChangePage({super.key, required this.seguro});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SeguroChangePage> {

  SeguroRemessa get seguro => widget.seguro;

  Future<Map<String, Map<int, Membro>>>? _future;

  int _selectedUser = 0;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _future = SgcProvider.i.getMembrosToChangeSeguro(seguro.codUsuario, seguro.codVida);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Transferir segurado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 70),
        child: Column(
          children: [
            SeguroRemessaTile(
              key: ValueKey(seguro),
              seguro: seguro,
            ),

            FutureBuilder(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: LinearProgressIndicator(),
                  );
                }

                final list = snapshot.requireData;

                return Column(
                  children: [
                    for(var group in list.keys)
                      Builder(builder: (context) {
                        final cods = list[group]!.keys.toList();

                        return Column(
                          children: [
                            const Divider(),

                            Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Text(group,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ListView.separated(
                              itemCount: cods.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, i) => const SizedBox(height: 2),
                              itemBuilder: (context, i) {
                                final codUser = cods[i];
                                final membro = list[group]![codUser]!;

                                return MembroTile(
                                  key: ValueKey(membro),
                                  membro: membro,
                                  dense: true,
                                  onTap: (membro) {
                                    _selectedUser = codUser;
                                    _setState();
                                  },
                                  trailing: Radio(
                                    value: codUser,
                                    groupValue: _selectedUser,
                                    onChanged: (value) {
                                      _selectedUser = value!;
                                      _setState();
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() :
      FloatingActionButton.extended(
        onPressed: _onSaveTap,
        label: const Text('Transferir Seguro'),
      ),
    );
  }

  void _onSaveTap() async {
    if (_selectedUser == 0) {
      Log.snack('Selecione um membro', isError: true);
      return;
    }

    _setInProgress(true);

    final body = {
      'cod_usuario': _selectedUser,
      'autor_cadastro': FirebaseProvider.i.user.codUsuario,
      'dt_cadastro': Formats.dataHoraUs(DateTime.now()),
      'Submit': 'Salvar',
      'MM_update': 'form1',
    };

    try {
      await SgcProvider.i.getMembrosToChangeSeguro(seguro.codUsuario, seguro.codVida, body: body);

      if (mounted) {
        Navigator.pop(context, true);
      }

      Log.snack('Dados salvos');
    } catch(e) {
      Log.snack('Erro ao salvar', isError: true);
    }
    _setInProgress(false);
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