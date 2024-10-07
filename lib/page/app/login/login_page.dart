import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<LoginPage> {

  final _log = const Log('LoginPage');

  String _email = '';
  String _codigo = '';
  String _anoNasc = '';
  String _usuario = '';
  String _senha = '';

  String? _key;

  final _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _loginEspecial = false;
  bool _inProgress = false;

  @override
  void initState() {
    super.initState();

    if (debugMode) {
      final env = dotenv.env;
      _email = env['EMAIL'] ?? '';
      _codigo = env['CODIGO'] ?? '';
      _anoNasc = env['ANO'] ?? '';

      _usuario = env['USUARIO'] ?? '';
      _senha = env['SENHA'] ?? '';
    } else {
      _email = pref.getString(PrefKey.userEmail);
      _codigo = pref.getString(PrefKey.userCodigo);
      _anoNasc = pref.getString(PrefKey.userAno);
    }
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.white;
    const style = TextStyle(
      color: textColor,
    );

    const padding = EdgeInsets.all(10);

    return Scaffold(
      backgroundColor: Tema.i.primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 60,
            right: 60,
            child: Image.asset(Assets.clubeLogo),
          ),  // logo

          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Tema.i.tintDecColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.topCenter,
                      child: Text('Informe seus dados',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),  // title

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          style: style,
                          initialValue: _email,
                          keyboardType: TextInputType.emailAddress,
                          inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            labelStyle: style,
                            prefixIconColor: textColor,
                            prefixIcon: Icon(Icons.person),
                            contentPadding: padding,
                          ),
                          onSaved: (value) => _email = value!,
                          validator: Validators.emailObrigatorio,
                        ),  // email

                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: _codigo,
                                style: style,
                                keyboardType: TextInputType.number,
                                inputFormatters: TextType.numero.inputFormatters,
                                decoration: const InputDecoration(
                                  labelText: 'Código',
                                  labelStyle: style,
                                  prefixIconColor: textColor,
                                  prefixIcon: Icon(Icons.https),
                                  contentPadding: padding,
                                ),
                                onSaved: (value) => _codigo = value!,
                                validator: Validators.obrigatorio,
                              ),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: _anoNasc,
                                style: style,
                                keyboardType: TextInputType.number,
                                inputFormatters: TextType.numero.inputFormatters,
                                decoration: const InputDecoration(
                                  labelText: 'Ano',
                                  labelStyle: style,
                                  prefixIconColor: textColor,
                                  prefixIcon: Icon(Icons.calendar_month),
                                  contentPadding: padding,
                                ),
                                onSaved: (value) => _anoNasc = value!,
                                validator: Validators.obrigatorio,
                              ),
                            ),
                          ],
                        ),  // codigo // ano

                        CheckboxListTile(
                          title: const Text('Login especial',
                            style: style,
                          ),
                          value: _loginEspecial,
                          onChanged: (value) {
                            _loginEspecial = value!;
                            if (!value) _key = null;
                            _setState();
                          },
                        ),

                        if (_loginEspecial)...[
                          TextFormField(
                            style: style,
                            initialValue: _usuario,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              labelText: 'Usuário SGC',
                              labelStyle: style,
                              prefixIconColor: textColor,
                              prefixIcon: Icon(Icons.person),
                              contentPadding: padding,
                            ),
                            onSaved: (value) => _usuario = value!,
                            validator: Validators.obrigatorio,
                          ),  // usuario

                          TextFormField(
                            style: style,
                            initialValue: _senha,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              labelText: 'Senha SGC',
                              labelStyle: style,
                              prefixIconColor: textColor,
                              prefixIcon: const Icon(Icons.https),
                              contentPadding: padding,
                              suffixIcon: IconButton(
                                tooltip: '${_obscureText ? 'Mostrar' : 'Ocultar'} senha',
                                onPressed: _onShowSenhaTap,
                                color: textColor,
                                icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                              ),
                            ),
                            onSaved: (value) => _senha = value!,
                            validator: Validators.obrigatorio,
                          ),  // senha

                          TextFormField(
                            style: style,
                            decoration: const InputDecoration(
                              labelText: 'Chave',
                              labelStyle: style,
                              prefixIconColor: textColor,
                              prefixIcon: Icon(Icons.key),
                            ),
                            onSaved: (value) => _key = value!,
                            validator: Validators.obrigatorio,
                          ),  // key
                        ],
                      ],
                    ), // form

                    const SizedBox(height: 10),

                    Column(
                      children: [
                        SizedBox(
                          width: 300,
                          child: ElevatedButton(
                            onPressed: _onLoginTap,
                            child: const Text('LOGIN'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (_inProgress)
                          const LinearProgressIndicator()
                        else
                          const SizedBox(height: 3),
                      ],
                    ),  // login

                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onLoginTap() async {
    final form = _formKey.currentState!;
    if (!form.validate()) return;
    form.save();

    _setInProgress(true);

    final fireProv = FirebaseProvider.i;

    try {
      if (_key == '') _key = null;
      if (_loginEspecial) {
        await SgcProvider.i.login(_usuario, _senha);
      }

      await CvProvider.i.login(_email, _codigo, _anoNasc, saveLogin: true);
      await fireProv.login(int.parse(_codigo), key: _key);

      if (!_loginEspecial) {
        await Future.wait([
          MembrosProvider.i.loadOnline(),
          ClubeProvider.i.loadOnline(fireProv.clubeId),
        ]);
      }

      if (!fireProv.readOnly) {
        EditMembrosProvider.i.loadOnline();
        EditEspecialidadesProvider.i.loadOnline();
      }
    } catch(e) {
      final erro = e.toString();
      if (erro.contains('Usuário não') ||
          erro.contains('ID do clube') ||
          erro.contains('chave informada')) {
        Log.snack(erro, isError: true);
      } else if (e is Map) {
        final data = e['data'] as Map? ?? {};
        if (data.containsKey('error')) {
          Log.snack(data['error'], isError: true);
        } else {
          Log.snack('Ocorreu um erro ao fazer login', isError: true);
        }
      } else {
        Log.snack('Ocorreu um erro ao fazer login', isError: true);
      }
      _log.e('_onLoginTap', e);

      await AppProvider.logout();
    }

    _setInProgress(false);
  }

  void _onShowSenhaTap() {
    _obscureText = !_obscureText;
    _setState();
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