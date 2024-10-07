import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../util/util.dart';
import '../../res/res.dart';
import '../page.dart';

class SgcPage extends StatefulWidget {
  final int? loginAction;
  const SgcPage({
    super.key,
    this.loginAction,
  });

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcPage> {

  final _formKey = GlobalKey<FormState>();

  int? get loginAction => widget.loginAction;

  late SgcProvider _sgcProvider = SgcProvider.i;

  String _usuario = '';
  String _senha = '';

  bool _obscureText = true;
  bool _autoLogin = false;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();

    if (kDebugMode) {
      final env = dotenv.env;
      _usuario = env['USUARIO'] ?? '';
      _senha = env['SENHA'] ?? '';
    } else {
      _usuario = pref.getString(PrefKey.userLogin);
      _senha = pref.getString(PrefKey.userSenha);
    }

    if (_usuario.isNotEmpty && _senha.isNotEmpty && !_sgcProvider.logado) {
      _autoLogin = true;
      _onLoginTap(true);
    }
    if (_sgcProvider.logado) {
      Future.delayed(const Duration(milliseconds: 100), _onLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    _sgcProvider = context.watch<SgcProvider>();

    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('SGC'),
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  if (!_sgcProvider.logado)...[
                    Colors.white,
                    Colors.white,
                  ] else...[
                    Colors.white,
                    Colors.white,
                  ],
                ],
              ),
            ),
          ),
          _body(),
        ],
      ),
      floatingActionButton: _inProgress ? const CircularProgressIndicator() : null,
    );
  }

  Widget _body() {
    if (_sgcProvider.logado) {
      return GridView(
        padding: const EdgeInsets.all(7),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 7,
          mainAxisSpacing: 7,
          childAspectRatio: 1,
        ),
        children: [
          SgcMenuItem(
            title: 'Membros',
            subtitle: 'Cadastrar, Atualizar\nImportar',
            icon: Icons.group,
            onTap: _onImportMembroTap,
          ),  // membros

          SgcMenuItem(
            onTap: _onAgendaTap,
            icon: Icons.calendar_month,
            title: 'Agenda',
            subtitle: 'Atividades do clube',
          ),  // agenda

          SgcMenuItem(
            onTap: _onEspecialidadesTap,
            icon: Icons.local_fire_department,
            title: 'Especialidades',
            subtitle: 'Atribuir Especialidades\naos membros',
          ),  // esp

          SgcMenuItem(
            onTap: _onClassesTap,
            icon: Icons.hotel_class,
            title: 'Classes',
            subtitle: 'Atribuir Classes\naos membros',
          ),  // classes

          SgcMenuItem(
            onTap: _onSeguroTap,
            icon: Icons.health_and_safety,
            title: 'Seguros',
            subtitle: 'Atualizar seguro\ndos membros',
          ),  // seguro

          SgcMenuItem(
            onTap: _onTesourariaTap,
            icon: Icons.monetization_on,
            title: 'Tesouraria',
            subtitle: 'Dados financeiros',
          ),  // Tesouraria

          SgcMenuItem(
            onTap: _onUnidadesTap,
            icon: Icons.groups,
            title: 'Unidades',
            // subtitle: 'Dados financeiros',
          ),  // Tesouraria
        ],
      );
    }

    if (_autoLogin) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrando na sua conta',
              style: TextStyle(
                fontSize: 22,
              ),
            ),

            LinearProgressIndicator(),

            Text('Sistema de Gerenciamento de Clubes',
              textAlign: TextAlign.center,
              style: TextStyle(
                // fontSize: 30,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    const tintColor = Colors.white;
    const style = TextStyle(color: tintColor);
    const space = SizedBox(height: 10);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            color: Tema.i.tintDecColor,
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                space,

                const Center(
                  child: Text('Fazer login',
                    style: TextStyle(
                      fontSize: 20,
                      color: tintColor,
                    ),
                  ),
                ),

                const Center(
                  child: Text('Sistema de Gerenciamento de Clubes',
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),

                space,

                TextFormField(
                  initialValue: _usuario,
                  style: style,
                  decoration: const InputDecoration(
                    labelText: 'Usuário',
                    labelStyle: style,
                    prefixIcon: Icon(Icons.person,
                      color: tintColor,
                    ),
                  ),
                  validator: Validators.obrigatorio,
                  onSaved: (value) => _usuario = value!,
                ),
                TextFormField(
                  initialValue: _senha,
                  obscureText: _obscureText,
                  style: style,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: style,
                    prefixIcon: const Icon(Icons.https,
                      color: tintColor,
                    ),
                    suffixIcon: IconButton(
                      tooltip: '${_obscureText ? 'Mostrar' : 'Ocultar'} senha',
                      onPressed: _onShowSenhaTap,
                      color: tintColor,
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    ),
                  ),
                  validator: Validators.obrigatorio,
                  onSaved: (value) => _senha = value!,
                ),

                space,

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onLoginTap,
                    child: const Text('Entrar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onLoginTap([bool autoLogin = false]) async {
    await Future.delayed(const Duration(milliseconds: 150));

    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    if (!autoLogin) {
      final form = _formKey.currentState!;
      if (!form.validate()) return;
      form.save();
    }

    _setInProgress(true);

    try {
      await _sgcProvider.login(_usuario, _senha);

      pref.setString(PrefKey.userLogin, _usuario);
      pref.setString(PrefKey.userSenha, _senha);

      _onLogin();
    } catch(e) {
      final erro = e.toString();
      var msg = 'Erro al fazer login';

      if (erro.contains('Usuário não encontrado')) {
        msg = 'Usuário não encontrado';
      }

      Log.snack(msg, isError: true, actionClick: () {
        DialogBox(
          context: context,
          title: 'Detalhes do erro',
          content: [
            Text(erro),
          ],
        ).ok();
      });
    }

    _setInProgress(false);
  }

  void _onLogin() {
    switch(loginAction) {
      case SgcLoginAction.membro:
        return _onImportMembroTap();
      case SgcLoginAction.especialidades:
        return _onEspecialidadesTap();
    }
  }

  void _onShowSenhaTap() {
    _obscureText = !_obscureText;
    _setState();
  }

  void _onImportMembroTap() async {
    Navigate.push(context, const SgcMembrosPage());
  }

  void _onEspecialidadesTap() async {
    Navigate.push(context, const SgcEspecialidadesPage());
  }

  void _onClassesTap() async {
    Navigate.push(context, const SgcClassesPage());
  }

  void _onSeguroTap() async {
    Navigate.push(context, const SeguroMainPage());
  }

  void _onAgendaTap() async {
    Navigate.push(context, const SgcAgendaPage());
  }

  void _onTesourariaTap() async {
    Navigate.push(context, const TesourariaPage());
  }

  void _onUnidadesTap() async {
    Navigate.push(context, const UnidadesPage());
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
