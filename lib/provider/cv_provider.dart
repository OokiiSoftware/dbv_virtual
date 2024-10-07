import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as html;
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class CvProvider extends IProvider {

  final _log = const Log('CvProvider');

  //region variaveis

  static const requestResultBody = 'Requisito atualizado com sucesso';
  static const requestUserNaoAuth = 'Membro não autenticado';

  CvProvider._();
  factory CvProvider() => i;
  static final CvProvider i = CvProvider._();

  final Map<String, Profile> _profiles = {};
  final Map<String, String> _tokens = {};

  bool get logado => _profiles.isNotEmpty;

  int _codUserLogado = 0;
  int starsCount = 0;

  Profile? getProfile(int codUser) => _profiles[_codToKey(codUser)];

  bool containsCod(int cod) => _tokens.containsKey(_codToKey(cod));

  //endregion

  //region login

  Future<void> login(String email, String codigo, String ano, {bool tryAgain = true, bool saveLogin = false}) async {
    verificarInternet();
    final key = '_$codigo';

    final body = {
      'email': email,
      'codigo': codigo,
      'ano': ano,
      'Logon': 'Entrar',
    };

    final res = await _post('https://clubes.adventistas.org/br/personal-card/', 0, body: body);

    if (res.body.contains('Nenhum membro encontrado')) {
      logout(int.tryParse(codigo));
      throw 'Usuário não encontrado: (${CvLoginStatus.naoExiste})';
    }

    if (res.body.contains('membros ativos do Sistema')) {
      logout(int.tryParse(codigo));
      throw 'Esse usuário está desativado: (${CvLoginStatus.desativado})';
    }

    if (res.body.contains('Termo de Adesão')) {
      logout(int.tryParse(codigo));
      throw 'Esse usuário está desativado: (${CvLoginStatus.desativado})';
    }

    final token = res.headers['set-cookie'] ?? '';

    if (token.isEmpty && tryAgain) {
      return await login(email, codigo, ano, tryAgain: false, saveLogin: saveLogin);
    }

    _tokens[key] = token;

    final prof = await loadProfile(int.parse(codigo), forceRefresh: true).catchError((e) {
      if (saveLogin) logout();
      throw e;
    });

    if (saveLogin) {
      pref.setString(PrefKey.userEmail, email);
      pref.setString(PrefKey.userCodigo, codigo);
      pref.setString(PrefKey.userAno, ano);

      _codUserLogado = int.parse(codigo);
    }

    _log.d('login', 'OK', prof?.user.nomeUsuario);
    notifyListeners();
  }

  Future<void> relogin(Profile? prof) async {
    if (prof == null) return;

    final user = prof.user;
    String email = user.emailUsuario;
    int codUser = user.codUsuario;
    int ano = user.dataNascimento?.year ?? 0;

    if (email.isEmpty || codUser == 0 || ano == 0) {
      return;
    }

    await login(email, '$codUser', '$ano');
  }

  void logout([int? codUser]) {
    if (codUser == null) {
      _profiles.clear();
      _log.d('logout');
    } else {
      _profiles.remove('_$codUser');
      _tokens.remove('_$codUser');
      _log.d('logout user', codUser);
    }
    notifyListeners();
  }

  //endregion

  //region send dados

  Future<http.Response> sendQuestao(int codUser, String url, Map<String, String> body) async {
    return await _post(url, codUser, body: body);
  }

  Future<http.Response> sendFile(int codUser, String url, {Uint8List? fileBytes, String? fileName, Map<String, String>? body, bool tryAgain = true}) async {
    return await _postFile(url, codUser, fileBytes: fileBytes, fileName: fileName, body: body, tryAgain: tryAgain);
  }

  //endregion

  //region get dados

  Future<Profile?> loadProfile(int codUser, {bool forceRefresh = false}) async {
    verificarInternet();
    final prof = _profiles[_codToKey(codUser)];
    if (prof != null && !forceRefresh) return prof;

    final res = await _post('https://clubes.adventistas.org/br/profile/', codUser);
    final profTemp = _userFronResponse(res.body);
    if (profTemp == null) throw 'Erro ao obter dados do membro';

    _profiles['_$codUser'] = profTemp;

    saveLocal();
    notifyListeners();
    return profTemp;
  }

  Future<void> loadClasses(int codUser, Classe classe, {bool forceRefresh = false}) async {
    verificarInternet();
    final prof = _profiles[_codToKey(codUser)];
    if (prof == null) throw requestUserNaoAuth;

    final classes = prof.classes;

    void setValues(Classe classe, String response) {
      final key = classe.id;

      classe = classes[key]!;
      List<Atividade> atividadesList = [];

      final doc = html.Document.html(response);
      final atividades = doc.getElementsByClassName('box box-primary');

      for (var element in atividades) {
        var questoes = element.getElementsByClassName('box-header with-border');
        var respostas = element.getElementsByClassName('box-body');
        if (questoes.isEmpty) continue;

        questoes = questoes.where((e) => !e.text.contains('Completar item')).toList();
        respostas = respostas.where((e) {
          if (e.parent!.className == 'box-body') {
            return false;
          }

          return true;// !e.text.contains('Enviar arquivo') && !e.text.contains('Responder requisito');
        }).toList();

        // print('------------');
        // print(questoes.length);
        // print(respostas.length);

        final atividade = Atividade();

        for (int i = 0; i < questoes.length; i++) {
          final questaoE = questoes[i];
          final child = questaoE.children.first;

          // if (questaoE.text.contains('Completar item') || questaoE.text.trim().isEmpty) continue;

          final name = questaoE.text.trimRight().trimLeft();

          final questao = Questao();
          if (child.localName == 'h3') {
            atividade.name = name;
          } else if (child.localName == 'h4') {
            if (!name.contains('SGC-EaD')) {
              questao.name = name;
            }
          } else if (child.localName == 'h5') {
            if (atividade.questoes.isEmpty) {
              atividade.questoes.add(Questao(name: name));
            } else {
              atividade.questoes.last.subQuestoes.add(Questao(name: name));
            }
          }

          if (questao.name.isNotEmpty) {
            atividade.questoes.add(questao);
          }
        }

        for (var q in atividade.questoes) {
          if (q.subQuestoes.length == 1) {
            q.name += '\n${q.subQuestoes.first.name}';
            q.subQuestoes.clear();
          }
        }

        int respostaPos = 0;

        void setQuestaoValues(Questao questao, [bool ignoreUrl = false]) {
          final res = respostas[respostaPos];
          final h5 = res.getElementsByTagName('h5');

          if (h5.isNotEmpty) {
            questao.data = h5[0].text.trimLeft().trimRight().replaceAll('Data: ', '');
            var resposta = h5[1].text.trimLeft().trimRight();
            questao.resposta = resposta.replaceAll('Relatório:', '').trimLeft();
            try {
              if (kReleaseMode) {
                questao.resposta = utf8.decode(questao.resposta.runes.toList());
              }
            } catch(e) {
              //
            }
          }

          // get url
          if (!ignoreUrl) {
            final script = res.getElementsByTagName('script');

            if (script.isEmpty) {
              respostaPos++;
              return setQuestaoValues(questao);
            }

            var url = script.first.text;

            const s = 'location.href="';
            int init = url.indexOf(s) + s.length;
            questao.url = url.substring(init, url.indexOf('"', init));
          }

          // verifica se é pergunta com arquivo
          final button = res.getElementsByTagName('button');
          if (button.isNotEmpty) {
            final text = button.first.text;
            questao.sendFile = text.contains('Enviar arquivo') || text.contains('Atualizar arquivo');

            if (questao.sendFile) {
              respostaPos++;
              return setQuestaoValues(questao, true);
            }
          }

          // get file url
          final iframe = res.getElementsByTagName('iframe');
          if (iframe.isNotEmpty) {
            var src = iframe.first.attributes['src'] ?? '';
            src = src.replaceAll('https://docs.google.com/viewer?url=', '');
            src = src.replaceAll('&embedded=true', '');
            questao.fileUrl = src;
            questao.fileName = src.replaceAll('https://sg.sdasystems.org/arquivos_cartoes/', '');
          }

          respostaPos++;
        }

        /// respostas
        for (int i = 0; i < atividade.questoes.length; i++) {
          final questao = atividade.questoes[i];

          if (questao.subQuestoes.isEmpty) {
            setQuestaoValues(questao);
          } else {
            for (int j = 0; j < questao.subQuestoes.length; j++) {
              final subquestao = questao.subQuestoes[j];
              setQuestaoValues(subquestao);
            }
          }
        }

        atividadesList.add(atividade);
      }

      if (atividadesList.isNotEmpty) {
        classe.atividades.clear();
        classe.atividades.addAll(atividadesList);
      }
    }

    final key = classe.id;

    if (classes.containsKey(key) && classes[key]!.atividades.isNotEmpty && !forceRefresh) {
      return;
    } else {
      classes[key] = classe;
    }

    final res = await _post(classe.url, codUser);

    if (res.body.contains('Acesso inválido')) {
      throw 'Não foi possível obter os dados.';
    }

    if (res.body.isEmpty) return;

    setValues(classe, res.body);
    notifyListeners();
    saveLocal();
  }

  //endregion

  //region posts

  Future<http.Response> _post(String url, int tokenKey, {Map<String, String>? body, bool tryAgain = true}) async {
    verificarInternet();

    List<String>? enc = [];
    body?.forEach((key, value) {
      if (key != 'texto') {
        enc!.add('${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}');
      } else {
        enc!.add('texto=$value');
      }
    });

    if (enc.isEmpty) enc = null;

    final res = await http.post(Uri.parse(url),
      body: enc?.join('&'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': 'https://clubes.adventistas.org/br/personal-card/',
        if (_tokens.containsKey(_codToKey(tokenKey)))
          'Cookie': _tokens[_codToKey(tokenKey)]!,
      },
      encoding: latin1,
    );

    if (res.body.contains('Acesso inválido') && tryAgain) {
      await relogin(_profiles[_codToKey(tokenKey)]);
      return _post(url, tokenKey, body: body, tryAgain: false);
    }

    if (res.statusCode != 200) throw res.body;

    return res;
  }

  Future<http.Response> _postFile(String url, int tokenKey, {Uint8List? fileBytes, String? fileName, Map<String, String>? body, bool tryAgain = true}) async {
    verificarInternet();

    var request = http.MultipartRequest('POST', Uri.parse(url));

    http.Response? res;
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      if (_tokens.containsKey(_codToKey(tokenKey)))
        'Cookie': _tokens[_codToKey(tokenKey)]!,
    });
    if (body != null) request.fields.addAll(body);

    if (fileBytes != null) {
      final fileData = http.MultipartFile.fromBytes(
        'arquivo',
        fileBytes,
        filename: fileName,
      );
      request.files.add(fileData);

      res = await http.Response.fromStream(await request.send());

      if (body?.containsKey('Submit2') ?? false) return res;
      if (body?['texto']?.isEmpty ?? false) return res;
    }

    if (res == null) {
      res = await _post(url, tokenKey, body: body, tryAgain: tryAgain);
    } else if (res.body.contains(requestResultBody)) {
      body?['arquivo2'] = fileName ?? '';
      res = await _post(url, tokenKey, body: body, tryAgain: tryAgain);
    }

    if (res.body.contains('Acesso inválido') && tryAgain) {
      await relogin(_profiles[_codToKey(tokenKey)]);
      return _postFile(url, tokenKey, fileBytes: fileBytes, fileName: fileName, body: body, tryAgain: false);
    }

    return res;
  }

  //endregion

  Future<void> init(Membro user) async {
    loadLocal();
    final item = Profile();
    item.user = user;
    _profiles[user.id] = item;
    _codUserLogado = user.codUsuario;
    await relogin(item);
  }

  Profile? _userFronResponse(String response) {
    if (response.isEmpty) return null;

    /// Alguns perfis tem dois elementos com o id=example1
    /// esse método remove o primeiro
    String removeForm() {
      const text = '<table id="example1';
      const textFim = '</table>';
      int init = response.indexOf(text);

      if (init < 0) return '';

      int fim = response.indexOf(textFim, init) + textFim.length;

      if (init > 0 && fim > init) {
        return response.substring(0, init) + response.substring(fim);
      }
      return '';
    }

    final doc = html.Document.html(response);
    final doc2 = html.Document.html(removeForm());
    final titles = doc.getElementsByTagName('title');
    if (titles.isEmpty) return null;

    final prof = Profile();

    final profile = doc.getElementsByClassName('box-body box-profile').where((e) => e.children.length > 1);
    final clube = doc.getElementsByClassName('box-body').where((e) => e.text.contains('Meu clube'));
    final tableClasses = doc.getElementById('example1');
    final tableClasses2 = doc2.getElementById('example1');
    final tableEspecialidades = doc.getElementById('example2');
    final tableEventos = doc.getElementById('example3');
    final tableHistorico = doc.getElementById('example4');
    final foto = doc.getElementsByClassName('profile-user-img img-responsive');
    final stars = doc.getElementsByClassName('fa fa-star text-yellow');

    starsCount = stars.length ~/ 2;

    if (foto.isNotEmpty) {
      var fotoLink = foto.first.attributes['src'] ?? '';
      fotoLink = fotoLink
          .replaceAll('https://sg.sdasystems.org/cms/fotos_membros/', '')
          .replaceAll('.jpg', '');

      prof.user.codUsuario = int.tryParse(fotoLink) ?? 0;
    }

    if (prof.user.codUsuario == 0) throw 'Código do membro inválido';

    prof.user.nomeUsuario = titles.first.text.replaceAll('Cartão Virtual - ', '');

    String elementToText(html.Element element) {
      return element.text.replaceAll('\n', '').trimRight().trimLeft();
    }

    if (clube.isNotEmpty) {
      final div = clube.first;
      final ps = div.getElementsByTagName('p');
      for (var p in ps) {
        var text = elementToText(p).replaceAll('Classificação:', '');
        prof.dados.add((text));
      }
      prof.dados.removeWhere((e) => e.isEmpty);
      prof.dados.removeLast();
    }

    if (profile.isNotEmpty) {
      final div = profile.first;
      final h4 = div.getElementsByTagName('h4');
      final p = div.getElementsByTagName('p');

      if (p.isNotEmpty) {
        final data = elementToText(p.first);
        prof.user.dtNascimento = data.substring(0, data.indexOf(' '));
      }
      if (h4.isNotEmpty) {
        prof.user.codFuncao = Util.codFuncaoByText(elementToText(h4.first));
      }
    }

    void preencherClasses(html.Element? element) {
      if (element == null) return;

      final tbodys = element.getElementsByTagName('tbody');
      if (tbodys.isNotEmpty) {
        final trs = tbodys.first.getElementsByTagName('tr');

        for (var tr in trs) {
          final tds = tr.getElementsByTagName('td');
          if (tds.isEmpty) continue;

          if (tds.length == 3) {/// classees concluidas
            prof.classesConcluidas.add([
              elementToText(tds[0]), // nome
              elementToText(tds[1]), // data
              // tds[2].children.first.attributes['href'] ?? '', // link certificado
            ]);
          } else {
            final url = tds[3].children.first.attributes['href'] ?? '';

            Classe item = Classe(
              name: elementToText(tds[0]),
              url: url,
              items: int.tryParse(elementToText(tds[1])) ?? 0,
              percent: double.tryParse(elementToText(tds[2]).replaceAll('%', '')) ?? 0,
            );

            final classeTemp = prof.classes[item.id];
            prof.classes[item.id] = item;
            if (classeTemp != null) {
              prof.classes[item.id]!.atividades.addAll(classeTemp.atividades);
            }
          }
        }
      }
    }

    preencherClasses(tableClasses);
    preencherClasses(tableClasses2);

    if (tableEspecialidades != null) {
      final tbody = tableEspecialidades.getElementsByTagName('tbody');
      if (tbody.isNotEmpty) {
        prof.especialiades.clear();

        final trs = tbody.first.getElementsByTagName('tr');
        for (var tr in trs) {
          final tds = tr.getElementsByTagName('td');
          final nome = elementToText(tds[0]);
          final data = elementToText(tds[1]);

          prof.especialiades.add([
            nome, data,
          ]);
        }
      }
    }

    if (tableEventos != null) {
      final tbody = tableEventos.getElementsByTagName('tbody');
      if (tbody.isNotEmpty) {
        prof.eventos.clear();

        final trs = tbody.first.getElementsByTagName('tr');
        for (var tr in trs) {
          final tds = tr.getElementsByTagName('td');
          final nome = elementToText(tds[0]);
          final data = elementToText(tds[3]);

          prof.eventos.add([
            nome, data,
          ]);
        }
      }
    }

    if (tableHistorico != null) {
      final tbody = tableHistorico.getElementsByTagName('tbody');
      if (tbody.isNotEmpty) {
        prof.historico.clear();

        final trs = tbody.first.getElementsByTagName('tr');
        for (var tr in trs) {
          final tds = tr.getElementsByTagName('td');
          final nome = elementToText(tds[0]);
          final data = elementToText(tds[2]);

          prof.historico.add([
            nome, data,
          ]);
        }
      }
    }

    return prof;
  }

  //region local dados

  @override
  void saveLocal() {
    final key = _codToKey(_codUserLogado);
    final user = _profiles[key];
    if (user == null) return;
    // database.child('profile').set(_profiles.map((key, value) => MapEntry(key, value.toJson())));
    database.child('profile').child(key).set(user.toJson());

    pref.setInt(PrefKey.starsCount, starsCount);
  }

  @override
  void loadLocal() {
    if (loadedLocal) return;
    try {
      final res = database.child('profile').get();
      _profiles.addAll(Profile.fromJsonList(res.value));
      notifyListeners();
    } catch(e) {
      _log.e('loadLocal', 'classes', e);
    }

    starsCount = pref.getInt(PrefKey.starsCount, def: 0);

    loadedLocal = true;
  }

  //endregion

  void notify() {
    notifyListeners();
  }

  @override
  Future<void> close() async {
    _profiles.clear();
    _tokens.clear();
    _codUserLogado = 0;
  }

  String _codToKey(int cod) => '_$cod';
}

class CvLoginStatus {
  static const naoExiste = '6548';
  static const desativado = '2357';
}
