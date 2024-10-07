import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as html;
import '../model/model.dart';
import '../util/util.dart';
import 'provider.dart';

class SgcProvider extends IProvider {

  final _log = const Log('SgcProvider');

  SgcProvider._();
  factory SgcProvider() => i;
  static final SgcProvider i = SgcProvider._();

  //region variaveis

  String _token = '';

  bool get logado => _token.isNotEmpty;

  final Map<int, Membro> membrosData = {};

  List<Membro> get membros => membrosData.values.toList();

  bool _membrosLoaded = false;

  //endregion

  //region load Dados

  Future<void> loadMembros({bool force = false, bool desativados = false}) async {
    if (_membrosLoaded && ! force) return;
    _membrosLoaded = true;

    const url = 'https://sg.sdasystems.org/cms/lista_usuario_clube.php';

    final body = [];
    if (desativados) {
      body.addAll([
        'status=N',
        'Submit=Filtrar dados',
        'ficha=0',
        'unidade=u.cod_usuario is not null',
        'funcao=u.cod_usuario is not null',
        'de=\'\'',
        'ate=100',
        'batismo=0',
      ]);
    }

    final res = await post(url, body: body);

    final doc = html.Document.html(res.body);
    var form = doc.getElementsByClassName('display');

    membrosData.clear();

    if (form.isEmpty) {
      notifyListeners();
      return;
    }

    var grade = desativados ? 'gradeX' : 'gradeA';

    final trs = form.first.getElementsByClassName(grade);

    String toString(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');

      final item = Membro(
        codUsuario: int.parse(toString(tds[1])),
        nomeUsuario: toString(tds[2]),
        //3 idade
        codFuncao: Util.codFuncaoByText(toString(tds[4])),
        //5 ativo
        segurado: toString(tds[6]) == 'SIM',
        fichaPendente: toString(tds[7]) == 'PENDENTE',
      );

      membrosData[item.codUsuario] = item;
    }

    notifyListeners();
    _saveLocalMembros(desativados);
  }

  Future<List<MembroEspecialidade>> loadEspecialidadesMembro(int codUser) async {
    final items = <MembroEspecialidade>[];

    final date = DateTime.now();
    var url = 'https://sg.sdasystems.org/cms/visualiza_membro_esp.php';
    url += '?cod_usuario=$codUser&dt1=1990-01-01&dt2=${Formats.dataUs(date)}';

    final res = await post(url);
    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');

    if (table == null) return items;

    String elementToString(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    final trs = table.getElementsByClassName('gradeA');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');

      int? codEsp;

      if (tds[5].children.isNotEmpty) {
        var link = tds[5].children.first.attributes['href'] ?? '';

        const text = 'cod_us_esp=';
        int init = link.indexOf(text) + text.length;
        int fim = link.indexOf('&', init);
        link = link.substring(init, fim);

        if (init > 0 && fim > init) {
          codEsp = int.tryParse(link);
        }
      }

      final item = MembroEspecialidade(
        id: elementToString(tds[0]),
        cod: codEsp ?? 0,
        nome: elementToString(tds[1]),
        instrutor: elementToString(tds[2]),
        data: elementToString(tds[3]),
      );

      items.add(item);
    }

    return items;
  }

  Future<List<MembroEspecialidade>> loadClassesMembro(int codUser) async {
    final items = <MembroEspecialidade>[];

    final date = DateTime.now();
    var url = 'https://sg.sdasystems.org/cms/visualiza_membro_classe.php';
    url += '?cod_usuario=$codUser&dt1=1990-01-01&dt2=${Formats.dataUs(date)}';

    final res = await post(url);
    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');

    if (table == null) return items;

    String elementToString(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    final trs = table.getElementsByClassName('gradeA');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');

      int? codEsp;

      if (tds[5].children.isNotEmpty) {
        var link = tds[5].children.first.attributes['href'] ?? '';

        const text = 'cod_us_classe=';
        int init = link.indexOf(text) + text.length;
        int fim = link.indexOf('&', init);
        link = link.substring(init, fim);

        if (init > 0 && fim > init) {
          codEsp = int.tryParse(link);
        }
      }

      final item = MembroEspecialidade(
        id: elementToString(tds[0]),
        cod: codEsp ?? 0,
        nome: elementToString(tds[1]),
        instrutor: elementToString(tds[2]),
        data: elementToString(tds[3]),
      );

      items.add(item);
    }

    return items;
  }


  @Deprecated('Descontinuado, use [getMembrosList]')
  Future<void> obterMembrosImport({bool force = false}) async {
    Map allData = {};
    String importMember = '';
    if (force) {
      final body = [];
      List<int> cods = [0, 1, 2, 5, 13, 14, 15, 16, 17, 29, 32, 36, 39, 40, 41, 45];
      body.add('example_length=100');
      body.addAll(cods.map((i) => 'coluna[]=$i').toList());
      body.add('selectAll=0');
      body.add('Exportar=Gerar+tabela');
      body.add('extend=csv');
      body.add('exportOptions={"columns": \':visible\'}');

      var res = await post('https://sg.sdasystems.org/cms/lista_usuario_clube.php');
      res = await post('https://sg.sdasystems.org/cms/relatorios/index.php', body: body);

      importMember = res.body;
    }

    if (importMember.isEmpty) throw 'Membros content está vazio';

    final doc = html.Document.html(importMember);
    final table = doc.getElementById('example');
    if (table == null) return;

    final trs = table.getElementsByTagName('tr');

    String getText(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    allData.clear();

    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      if (tds.isEmpty) continue;

      Map<String, dynamic> data = {};
      data['codigo'] = getText(tds[data.length]);
      data['nome'] = getText(tds[data.length]);
      data['cargo'] = getText(tds[data.length]);
      // data['lider'] = getText(tds[data.length]); //
      // data['descricao'] = getText(tds[data.length]); //
      data['dataNasc'] = getText(tds[data.length]);
      // data['sexo'] = getText(tds[data.length]); //
      // data['certidao'] = getText(tds[data.length]); //
      // data['rg'] = getText(tds[data.length]); //
      // data['orgaoExpedidor'] = getText(tds[data.length]); //
      // data['cfp'] = getText(tds[data.length]); //
      // data['cpfResponsavel'] = getText(tds[data.length]); //
      // data['telefone'] = getText(tds[data.length]); //
      data['celular'] = getText(tds[data.length]);
      data['email'] = getText(tds[data.length]);
      data['rua'] = getText(tds[data.length]);
      data['bairro'] = getText(tds[data.length]);
      data['cep'] = getText(tds[data.length]);
      // data['nomePai'] = getText(tds[data.length]); //
      // data['emailPai'] = getText(tds[data.length]); //
      // data['telefonePai'] = getText(tds[data.length]); //
      // data['nomeMae'] = getText(tds[data.length]); //
      // data['emailMae'] = getText(tds[data.length]); //
      // data['telefoneMae'] = getText(tds[data.length]); //
      // data['responsavel'] = getText(tds[data.length]); //
      // data['vinculoResponsavel'] = getText(tds[data.length]); //
      // data['emailResponsavel'] = getText(tds[data.length]); //
      // data['telefoneResponsavel'] = getText(tds[data.length]); //
      // data['observacao'] = getText(tds[data.length]); //
      data['camisa'] = getText(tds[data.length]);
      // data['batizado'] = getText(tds[data.length]); //
      // data['codigoUnidade'] = getText(tds[data.length]); //
      data['unidade'] = getText(tds[data.length]);
      // data['nomeClube'] = getText(tds[data.length]); //
      // data['codigoArea'] = getText(tds[data.length]); //
      // data['nomeArea'] = getText(tds[data.length]); //
      data['cidade'] = getText(tds[data.length]);
      // data['acesso'] = getText(tds[data.length]); //
      // data['idade'] = getText(tds[data.length]); //
      data['dataFicha'] = getText(tds[data.length]);
      data['dataTermo'] = getText(tds[data.length]);
      data['statusTermo'] = getText(tds[data.length]);
      // data['vinculo1'] = getText(tds[data.length]); //
      // data['vinculo2'] = getText(tds[data.length]); //
      // data['vinculo3'] = getText(tds[data.length]); //
      data['seguroDireto'] = getText(tds[data.length]);
      // data['seguroIndireto'] = getText(tds[data.length]); //
      // data['seguroOutroMinisterio'] = getText(tds[data.length]); //
      // data['validacao'] = getText(tds[data.length]); //
      // data['codigo2'] = getText(tds[data.length]); //
      data['pais'] = 'BR';

      allData[data['codigo']] = data;
    }

    notifyListeners();
  }

  @Deprecated('Descontinuado, use [getMembrosList]')
  Future<String> importarMembros(List<String> codigos) async {
    Map allData = {};
    List<Membro> membros = [];

    String erros = '';

    for (var cod in codigos) {
      final value = allData[cod];
      if (value == null) continue;

      try {
        final nome = value['nome'];
        final query = MembrosProvider.i.query(nome);

        final membro = Membro.fromJson({
          'nome_usuario': nome,
          'email_usuario': value['email']?.toString().toLowerCase(),
          'cod_usuario': value['codigo'],
          'dt_nascimento': value['dataNasc'],
          'cep_usuario': value['cep'],
          'end_usuario': value['rua'],
          'cod_cidade': value['cidade'],
          'bairro_usuario': value['bairro'],
          'cod_funcao': value['cargo'],
          'cel_usuario': value['celular'],
          'cod_camiseta': value['camisa'],

          'unidade': value['unidade'],
          'dataFicha': value['dataFicha'],
          'dataTermo': value['dataTermo'],
          'statusTermo': value['statusTermo'],
          'seguroDireto': value['seguroDireto'],
        });

        if (query.isEmpty) {
          await FirebaseProvider.i.criarIdentificador(membro.id);
        }

        membros.add(membro);

        for (var value in membros) {
          await MembrosProvider.i.add(value);
        }
      } catch(e) {
        if (e.toString().contains('auth credential is incorrect')) {
          erros += 'O email informado é inválido: ${value['email']}';
        } else {
          erros += '$e\n';
        }
      }
    }

    return erros;
  }

  //endregion

  //region get Dados

  Future<List<Membro>> getMembrosList() async {
    await loadMembros();
    return membros;
  }

  Future<Membro> getMembro(int cod) async {
    var url = 'https://sg.sdasystems.org/cms/atualiza_usuario_clube.php';
    url += '?cod_usuario=$cod&seguro=1';

    final res = await post(url);
    Map dados = _mapFromResponse(res.body);
    dados['segurado'] = membrosData[cod]?.segurado;
    dados['fichaPendente'] = membrosData[cod]?.fichaPendente;

    return Membro.fromJson(dados);
  }


  Future<Map<String, Especialidade>> getEspecialidades() async {
    Map<String, Especialidade> especialidadesData = {};

    const uri = 'https://sg.sdasystems.org/cms/biblioteca_especialidades.php';
    final res = await post(uri);

    final doc = html.Document.html(res.body);
    final trs = doc.getElementsByClassName('gradeA');

    String toString(html.Element element) {
      return element.text.trimLeft().trimRight();
    }

    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      var link = tds[4].children.first.attributes['href'] ?? '';
      var cod = link.replaceAll('biblioteca_esp_ver.php?cod_esp=', '');
      cod = cod.replaceAll('&cod_idioma=1', '');

      final esp = Especialidade(
        idName: toString(tds[0]),
        nome: toString(tds[1]),
        area: toString(tds[2]),
        departamento: toString(tds[3]),
        cod: int.parse(cod),
      );
      especialidadesData[esp.id] = esp;
    }

    notifyListeners();
    return especialidadesData;
  }

  Future<String> getEspecialidadeText(int cod) async {
    final uri = 'https://sg.sdasystems.org/cms/biblioteca_esp_ver.php?cod_esp=$cod&cod_idioma=1';
    final res = await post(uri);

    final doc = html.Document.html(res.body);
    final textDiv = doc.getElementsByClassName('fonte12simples');
    if (textDiv.isEmpty) return '';

    return textDiv.last.text.trimRight().trimLeft();
  }


  Future<int> getCodClube() async {
    final res = await post('https://sg.sdasystems.org/cms/inicio.php');

    final regex = RegExp(r"[^\d]+");

    final doc = html.Document.html(res.body);
    final a = doc.getElementsByClassName('link6');
    for (var element in a) {
      var link = element.attributes['href'] ?? '';
      if (!link.contains('https://clubes.adventistas.org')) continue;

      final cod = link.replaceAll(regex, '');
      return int.tryParse(cod) ?? 0;
    }

    return 0;
  }

  Future<FichaMedica> getFichaMedica(int codUsuario) async {
    var url = 'https://sg.sdasystems.org/cms/ficha_usuario_clube.php';
    url += '?cod_usuario=$codUsuario';
    final res = await post(url);

    Map dados = _mapFromResponse(res.body);
    return FichaMedica.fromJson(dados);
  }

  Future<List<SeguroRemessa>> getRemessaSeguros() async {
    List<SeguroRemessa> items = [];

    const url = 'https://sg.sdasystems.org/cms/lista_seguro_remessa.php';
    final res = await post(url);

    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');
    if (table == null) return items;

    String elementToString(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    final tbodys = table.getElementsByTagName('tbody');
    if (tbodys.isEmpty) return items;

    final trs = tbodys.first.getElementsByTagName('tr');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      var codVida = 0;
      var canDelete = false;
      // Cod (0), Nome (1), Ativo (2), Função (3), Idade (4), Clube (5), Data Remessa (6), Link (7)

      if (tds[7].children.isNotEmpty) {
        final a = tds[7].children.first;
        final link = a.attributes['href'] ?? '';
        codVida = int.tryParse(link.split('=').last) ?? 0;
        canDelete = link.contains('exclui_segurado_clube');
      }

      items.add(SeguroRemessa(
        codUsuario: int.parse(elementToString(tds[0])),
        nomeUsuario: elementToString(tds[1]),
        ativo: elementToString(tds[2]) == 'SIM',
        funcao: elementToString(tds[3]),
        codVida: codVida,
        canDelete: canDelete,
      ));
    }

    return items;
  }

  Future<Map<String, Map<int, Membro>>> getMembrosToChangeSeguro(int codUser, int codVida, {Map? body}) async {
    Map<String, Map<int, Membro>> items = {};

    var url = 'https://sg.sdasystems.org/cms/troca_segurado_clube.php';
    url += '?cod_usuario=$codUser&cod_vida=$codVida';

    final res = await post(url, body: body);

    /// se body != null significa que estou enviando dados (não recebendo)
    if (body != null) return items;

    final doc = html.Document.html(res.body);
    final select = doc.getElementById('cod_usuario');

    if (select == null) return items;

    final optGroups = select.getElementsByTagName('optgroup');

    for (var group in optGroups) {
      if (!group.attributes.containsKey('label')) continue;

      items[group.attributes['label']!] = {};

      for (var opt in group.children) {
        final cod = int.parse(opt.attributes['value']!);
        final nome = opt.text.trimLeft().trimRight();

        items[group.attributes['label']!]![cod] = Membro(
          codUsuario: cod,
          nomeUsuario: nome,
        );
      }
    }

    return items;
  }

  Future<List<Membro>> getMembrosToAddSeguro({List? body}) async {
    List<Membro> items = [];

    const url = 'https://sg.sdasystems.org/cms/lista_seguro_clube.php';
    final res = await post(url, body: body);

    if (body != null) return items;

    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');
    if (table == null) return items;

    String elementToString(html.Element element) {
      return element.text.trimRight().trimLeft();
    }

    final tbodys = table.getElementsByTagName('tbody');
    if (tbodys.isEmpty) return items;

    final trs = tbodys.first.getElementsByTagName('tr');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');

      // Check (0), Cod (1), Nome (2), Função (3), Idade (4), Status (5), Atualizar (6), Transferir (7), Inativar (8)

      items.add(Membro(
        codUsuario: int.parse(elementToString(tds[1])),
        nomeUsuario: elementToString(tds[2]),
      ));
    }

    return items;
  }

  Future<List<SaudeGrafico>> getSaudeChart() async {
    const url = 'https://sg.sdasystems.org/cms/lista_clube_saude.php';
    final res = await post(url);

    final doc = html.Document.html(res.body);
    final tables = doc.getElementsByClassName('display');

    Map<String, int> getDadosFromTable(int index) {
      Map<String, int> items = {};

      if (index >= tables.length) return items;
      final table = tables[index];

      String elementToString(html.Element element) {
        return element.text.trimRight().trimLeft();
      }

      final tbodys = table.getElementsByTagName('tbody');
      if (tbodys.isEmpty) return items;

      final trs = tbodys.first.getElementsByTagName('tr');
      for (var tr in trs) {
        final tds = tr.getElementsByTagName('td');

        // Nome (0), Count (1), % (2), Ver (3)

        items[elementToString(tds[0])] = int.parse(elementToString(tds[1]));
      }

      return items;
    }

    List<SaudeGrafico> items = [];

    items.add(SaudeGrafico(
      title: 'Plano de Saúde e Saúde Pública',
      values: getDadosFromTable(0),
    ));

    items.add(SaudeGrafico(
      title: 'Doenças',
      values: getDadosFromTable(1),
    ));

    items.add(SaudeGrafico(
      title: 'Observações',
      values: getDadosFromTable(2),
    ));

    return items;
  }

  Future<List<Evento>> getAgenda(int ano, {void Function(int)? onProgress}) async {
    Map<int, Evento> mapItems = {};

    for (int mes = 1; mes <= 12; mes++) {
      onProgress?.call(mes);

      var url = 'https://sg.sdasystems.org/cms/lista_calendario_clube.php';
      url += '?mes=$mes&ano=$ano';

      final res = await post(url);

      String getValue(String value) {
        return value.split('=').last;
      }
      List<String> datas = [];

      final doc = html.Document.html(res.body);
      final tables = doc.getElementsByClassName('fundoform');
      if (tables.isEmpty) continue;

      final trs = tables.first.getElementsByTagName('tr');
      for (var tr in trs) {
        final tds = tr.getElementsByTagName('td');
        if (tds.length == 4) {
          final td = tds[2];
          if (td.children.isEmpty) continue;
          final tag = td.children.first;
          if (tag.localName != 'strong') continue;

          final text = tag.text.replaceAll('\n', '').replaceAll(' ', '').trimLeft().trimRight();
          if (Formats.stringToDateTime(text.split('-').first) != null) {
            datas.add(text);
          }
          continue;
        }

        if (tds.length != 5) continue;

        final td = tds[3];

        final text = td.text.trimRight().trimLeft();
        if (text.trim().isEmpty) continue;

        if (td.children.isEmpty) {
          mapItems.values.last.codTipoAgenda = Util.codTipoEventoByText(text);
          continue;
        }

        final a = td.children.first;

        var link = a.attributes['href'] ?? '';
        //cod_agenda=4961564&tipo=1&dia=25&mes=8&ano=2024
        final atributes = link.split('?').last;
        //[cod_agenda=4961564, tipo=1, dia=25, mes=8, ano=2024]
        var sp = atributes.split('&');

        final data = datas.last.split('-');

        final evento = Evento(
          codAgenda: int.parse(getValue(sp[0])),
          codTipoAgenda: int.parse(getValue(sp[1])),
          dtAgenda: data[0],
          dtAgendaFim: data[1],
          nomeAgenda: text,
        );

        if (mapItems.containsKey(evento.codAgenda)) {
          mapItems[evento.codAgenda]!.dtAgendaFim = evento.dtAgenda;
        } else {
          mapItems[evento.codAgenda] = evento;
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return mapItems.values.toList();
  }


  Future<List<Evento>> getEventos(int mes, int ano) async {
    Map<int, Evento> mapItems = {};

    var url = 'https://sg.sdasystems.org/cms/lista_calendario_clube.php';
    url += '?mes=$mes&ano=$ano';

    final res = await post(url);

    String getValue(String value) {
      return value.split('=').last;
    }
    List<String> datas = [];

    final doc = html.Document.html(res.body);
    final tables = doc.getElementsByClassName('fundoform');
    if (tables.isEmpty) return [];

    final trs = tables.first.getElementsByTagName('tr');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      if (tds.length == 4) {
        final td = tds[2];
        if (td.children.isEmpty) continue;
        final tag = td.children.first;
        if (tag.localName != 'strong') continue;

        final text = tag.text.replaceAll('\n', '').replaceAll(' ', '').trimLeft().trimRight();
        if (Formats.stringToDateTime(text.split('-').first) != null) {
          datas.add(text);
        }
        continue;
      }

      if (tds.length != 5) continue;

      final td = tds[3];

      final text = td.text.trimRight().trimLeft();
      if (text.trim().isEmpty) continue;

      if (td.children.isEmpty) {
        mapItems.values.last.codTipoAgenda = Util.codTipoEventoByText(text);
        continue;
      }

      final a = td.children.first;

      var link = a.attributes['href'] ?? '';
      //cod_agenda=4961564&tipo=1&dia=25&mes=8&ano=2024
      final atributes = link.split('?').last;
      //[cod_agenda=4961564, tipo=1, dia=25, mes=8, ano=2024]
      var sp = atributes.split('&');

      final data = datas.last.split('-');

      final evento = Evento(
        codAgenda: int.parse(getValue(sp[0])),
        codTipoAgenda: int.parse(getValue(sp[1])),
        dtAgenda: data[0],
        dtAgendaFim: data[1],
        nomeAgenda: text,
      );

      if (mapItems.containsKey(evento.codAgenda)) {
        mapItems[evento.codAgenda]!.dtAgendaFim = evento.dtAgenda;
      } else {
        mapItems[evento.codAgenda] = evento;
      }
    }

    return mapItems.values.toList();
  }

  Future<List<Evento>> getEventosOld(int mes, int ano) async {
    Map<int, Evento> mapItems = {};

    var url = 'https://sg.sdasystems.org/cms/lista_calendario_clube.php';
    url += '?mes=$mes&ano=$ano';

    final res = await post(url);

    String getValue(String value) {
      return value.split('=').last;
    }

    final doc = html.Document.html(res.body);
    final as = doc.getElementsByClassName('link5');
    for (var a in as) {
      //ver_agenda_clube.php?cod_agenda=4961564&tipo=1&dia=25&mes=8&ano=2024
      var link = a.attributes['href'] ?? '';
      //cod_agenda=4961564&tipo=1&dia=25&mes=8&ano=2024
      final atributes = link.split('?').last;
      //[cod_agenda=4961564, tipo=1, dia=25, mes=8, ano=2024]
      var sp = atributes.split('&');
      var dia = getValue(sp[2]);
      var mes = getValue(sp[3]);
      final ano = getValue(sp[4]);

      if (dia.length == 1) dia = '0$dia';
      if (mes.length == 1) mes = '0$mes';

      final evento = Evento(
        codAgenda: int.parse(getValue(sp[0])),
        codTipoAgenda: int.parse(getValue(sp[1])),
        dtAgenda: '$dia/$mes/$ano',
        nomeAgenda: a.text.trimLeft().trimRight(),
      );

      if (mapItems.containsKey(evento.codAgenda)) {
        mapItems[evento.codAgenda]!.dtAgendaFim = evento.dtAgenda;
      } else {
        mapItems[evento.codAgenda] = evento;
      }
    }

    return mapItems.values.toList();
  }

  Future<Evento?> getEvento(int codEvento, int dia, int mes, int ano, int codTipo) async {
    var url = 'https://sg.sdasystems.org/cms/ver_agenda_clube.php';
    url += '?&cod_agenda=$codEvento&tipo=$codTipo&dia=$dia&mes=$mes&ano=$ano';

    final res = await post(url);

    final doc = html.Document.html(res.body);
    final forms = doc.getElementsByClassName('detalhe');

    if (forms.isEmpty) return null;

    Map<String, String> dados = {};

    final trs = forms.first.getElementsByTagName('tr');
    for (var tr in trs) {
      final text = tr.text.replaceAll('\n', '').replaceAll('  ', '').trimLeft().trimRight().trim();
      if (text.isEmpty) continue;

      final sp = text.split(':');
      final key = sp[0];
      final value = sp[1];

      dados[key] = value;
    }

    return Evento(
      nomeAgenda: dados['Título'] ?? '',
      descAgenda: dados['Descrição'] ?? '',
      dtAgenda: dados['Início'] ?? '',
      dtAgendaFim: dados['Término'] ?? '',
      dtLembrete: dados['Data do lembrete'] ?? '',
      emailLembrete: dados['E-mail'] ?? '',
      txtLembrete: dados['Lembrete'] ?? '',
      opcao: dados['E-mail'] != null,
      codTipoAgenda: codTipo,
      codAgenda: codEvento,
    );
  }


  Future<Map<String, PagamentoSgc>> getContas(bool isReceita, {Map<String, String>? body}) async {
    Map<String, PagamentoSgc> items = {};
    String url;
    if (isReceita) {
      url = 'https://sg.sdasystems.org/cms/lista_fin_areceber.php';
    } else {
      url = 'https://sg.sdasystems.org/cms/lista_fin_apagar.php';
    }

    final res = await post(url, body: body);
    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');
    if (table == null) return items;

    String elementToString(html.Element value) {
      return value.text.trimRight().trimLeft();
    }

    final trs = table.getElementsByClassName('gradeA');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      // 0-Status, 1-Descrição, 2-Membro, 3-Vencimento, 4-Pago, 5-Valor, ver, alterar, excluir

      final element = tds[0];
      final cod = element.children.first.attributes['value'] ?? '0';

      final item = PagamentoSgc(
        codPagtoConta: int.parse(cod),
        descricao: elementToString(tds[1]),
        nomeMembro: elementToString(tds[2]),
        dtVencimento: elementToString(tds[3]),
        dtPagto: elementToString(tds[4]),
        valor: double.tryParse(elementToString(tds[5]).replaceAll('.', '').replaceAll(',', '.')) ?? 0,
      );
      items[item.id] = item;
    }

    return items;
  }

  Future<PagamentoSgc> getConta(PagamentoSgc conta) async {
    const error = 'Conta de pagamento não encontrado';

    final url = 'https://sg.sdasystems.org/cms/atualiza_fin_areceber.php?cod_pagto_conta=${conta.codPagtoConta}';
    final res = await post(url);
    final doc = html.Document.html(res.body);
    final seletcCodConta = doc.getElementById('cod_conta');
    final seletcCodMembro = doc.getElementById('cod_membro');
    final textAreaObs = doc.getElementsByClassName('textarea').first;

    if (seletcCodConta == null) throw error;
    if (seletcCodMembro == null) throw error;

    String getId(html.Element e) {
      bool containsKey(html.Element e) {
        return e.attributes.containsKey('selected') || e.attributes.containsKey('SELECTED');
      }

      for (var e in e.children) {
        if (containsKey(e)) return e.attributes['value'] ?? '0';
      }
      return '0';
    }

    final codConta = getId(seletcCodConta);
    final codMembro = getId(seletcCodMembro);

    return conta.copy(
      codConta: int.parse(codConta),
      codMembro: int.parse(codMembro),
      obs: textAreaObs.text.trimLeft().trimRight(),
    );
  }


  Future<Map<String, Unidade>> getUnidades() async {
    Map<String, Unidade> items = {};

    const url = 'https://sg.sdasystems.org/cms/lista_unidades_clube.php';
    final res = await post(url);
    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');
    if (table == null) return items;

    String elementToString(html.Element value) {
      return value.text.trimRight().trimLeft();
    }

    final trs = table.getElementsByClassName('gradeA');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      // 0-id, 1-nome, 2-conselheiro, 3-classes %, 4-relatorios, 5-ranking, 6-membros, 7-relatorio, 8-relatorioss, alterar, excluir

      final item = Unidade(
        codUnidade: int.parse((elementToString(tds[0]))),
        nomeUnidade: elementToString(tds[1]),
        nomeConselheiro: elementToString(tds[2]),
        membrosCount: int.parse(elementToString(tds[6])),
        canDelete: tds[10].children.isNotEmpty,
      );
      items[item.id] = item;
    }

    return items;
  }

  /// Retorna os conselheiros que podem ser atribuidos na unidade
  Future<List<int>> getUnidadeConselheiros() async {
    const error = 'Erro ao obter dados';
    List<int> items = [];

    const url = 'https://sg.sdasystems.org/cms/cad_unidade.php';
    final res = await post(url);
    final doc = html.Document.html(res.body);
    final seletcCodConselheiro = doc.getElementById('cod_conselheiro');

    if (seletcCodConselheiro == null) throw error;

    for (var option in seletcCodConselheiro.children) {
      final value = option.attributes['value'] ?? '0';
      final cod = int.tryParse(value) ?? 0;

      if (cod != 0) items.add(cod);
    }

    return items;
  }

  Future<Unidade> getUnidade(Unidade unidade, {bool send = false}) async {
    const error = 'Unidade não encontrada';

    final isNovo = unidade.codUnidade == 0;

    String url;
    if (isNovo) {
      url = 'https://sg.sdasystems.org/cms/cad_unidade.php';
    } else {
      url = 'https://sg.sdasystems.org/cms/atualiza_unidade.php?cod_unidade=${unidade.codUnidade}';
    }

    Map<String, String>? body;
    if (send) {
      body = {
        'Submit': 'Salvar',
        if (isNovo)
          'MM_insert': 'form1'
        else
          'MM_update': 'form1',
      };

      unidade.toJson().forEach((key, value) {
        body![key] = '$value';
      });
    }

    final res = await post(url, body: body);
    if (send) return unidade;

    final doc = html.Document.html(res.body);
    final campos = doc.getElementsByClassName('campo');
    final seletcCodConselheiro = doc.getElementById('cod_conselheiro');
    final historico = doc.getElementById('historico');
    final extras = doc.getElementById('extras');
    int senha = 0;

    if (seletcCodConselheiro == null) throw error;

    String getId(html.Element e) {
      bool containsKey(html.Element e) {
        return e.attributes.containsKey('selected') || e.attributes.containsKey('SELECTED');
      }

      for (var e in e.children) {
        if (containsKey(e)) return e.attributes['value'] ?? '0';
      }
      return '0';
    }

    final codConselheiro = getId(seletcCodConselheiro);

    for (var option in seletcCodConselheiro.children) {
      final value = option.attributes['value'] ?? '0';
      final cod = int.tryParse(value) ?? 0;

      if (cod != 0) unidade.conselheiroIds.add(cod);
    }

    for (var e in campos) {
      if (e.attributes['name'] == 'senha') {
        final s = e.attributes['value'] ?? '0';
        senha = int.tryParse(s) ?? 0;
      }
    }

    return unidade.copy(
      codConselheiro: int.parse(codConselheiro),
      historico: historico?.text,
      extras: extras?.text,
      senha: senha,
    );
  }

  Future<List<UnidadeMembro>> getUnidadeMembros() async {
    List<UnidadeMembro> items = [];

    const url = 'https://sg.sdasystems.org/cms/lista_un_membros.php';
    final res = await post(url);
    final doc = html.Document.html(res.body);
    final table = doc.getElementById('example');
    if (table == null) return items;

    String elementToString(html.Element value) {
      return value.text.trimRight().trimLeft();
    }

    final trs = table.getElementsByClassName('gradeA');
    for (var tr in trs) {
      final tds = tr.getElementsByTagName('td');
      // 0-checkbox, 1-idMembro, 2-nomeMembro, 3-função, 4-idade, 5-unidade, 6-pontos

      final element = tds[0];
      final cod = element.children.first.attributes['value'] ?? '0';

      final item = UnidadeMembro(
        codMembro: int.parse(cod),
        nomeUnidade: elementToString(tds[5]),
      );
      items.add(item);
    }

    return items;
  }

  /// Retorna uma lista de unidades e lista de ids de membros
  Future<MembrosUnidade> getUnidadeMembroIds([List<String>? body]) async {
    final unidade = MembrosUnidade();

    const url = 'https://sg.sdasystems.org/cms/cad_membro_unidade.php';
    final res = await post(url, body: body);
    if (body != null) return unidade;

    final doc = html.Document.html(res.body);
    final seletcCodUnidades = doc.getElementById('cod_unidade');
    final inputs = doc.getElementsByTagName('input');

    if (seletcCodUnidades == null) throw 'Erro ao obter os dados';

    for (var option in seletcCodUnidades.children) {
      final codS = option.attributes['value'] ?? '0';
      final value = option.text.trimRight().trimLeft();
      int cod = int.tryParse(codS) ?? 0;

      if (cod != 0) unidade.unidades[cod] = value;
    }

    inputs.removeWhere((e) => !(e.attributes['name']?.contains('cod_usuario') ?? true));

    for (var e in inputs) {
      final codS = e.attributes['value'] ?? '0';
      int cod = int.tryParse(codS) ?? 0;

      if (cod != 0) unidade.membroCods.add(cod);
    }

    return unidade;
  }

  //endregion

  //region send Dados

  Future<void> enviarEspecialidades(List<Membro> membros, List<Especialidade> especialidades, Map body) async {
    final bool porMembro = especialidades.length > membros.length;

    Future<void> sendPorMembro() async {
      const url = 'https://sg.sdasystems.org/cms/cad_esp_membro3.php';

      List bodyList = [];
      body.forEach((key, value) {
        bodyList.add('$key=$value');
      });
      List<int> cods = especialidades.map((e) => e.cod).toList();
      bodyList.addAll(cods.map((i) => 'cod_esp[]=$i').toList());

      bodyList.add('Submit=Salvar');
      bodyList.add('MM_insert=form1');

      for (var e in membros) {
        final cod = e.codUsuario;
        bodyList.add('cod_usuario=$cod');

        try {
          await post(url, body: bodyList);
        } catch(e) {
          _log.e('SgcProvider', 'enviarEspecialidades', 'porMembro', porMembro, e);
        }

        bodyList.remove('cod_usuario=$cod');
      }
    }

    Future<void> sendPorEsp() async {
      const url = 'https://sg.sdasystems.org/cms/cad_esp_membro2.php';

      List bodyList = [];
      body.forEach((key, value) {
        bodyList.add('$key=$value');
      });
      List<int> cods = membros.map((e) => e.codUsuario).toList();
      bodyList.addAll(cods.map((i) => 'cod_usuario[]=$i').toList());

      bodyList.add('Submit=Salvar');
      bodyList.add('MM_insert=form1');

      for (var e in especialidades) {
        final cod = e.cod;
        bodyList.add('cod_esp=$cod');

        try {
          await post(url, body: bodyList);
        } catch(e) {
          _log.e('SgcProvider', 'enviarEspecialidades', 'porMembro', porMembro, e);
        }

        bodyList.remove('cod_esp=$cod');
      }
    }

    if (porMembro) {
      await sendPorMembro();
    } else {
      await sendPorEsp();
    }
  }

  Future<void> enviarClasses(List<Membro> membros, List<ClasseItem> classes, Map body) async {
    final bool porMembro = classes.length > membros.length;

    Future<void> sendPorMembro() async {
      const url = 'https://sg.sdasystems.org/cms/cad_class_membro3.php';

      List bodyList = [];
      body.forEach((key, value) {
        bodyList.add('$key=$value');
      });
      List<int> cods = classes.map((e) => e.cod).toList();
      bodyList.addAll(cods.map((i) => 'cod_classe[]=$i').toList());

      bodyList.add('Submit=Salvar');
      bodyList.add('MM_insert=form1');

      for (var e in membros) {
        final cod = e.codUsuario;
        bodyList.add('cod_usuario=$cod');

        try {
          await post(url, body: bodyList);
        } catch(e) {
          _log.e('SgcProvider', 'enviarClasses', 'porMembro', porMembro, e);
        }

        bodyList.remove('cod_usuario=$cod');
      }
    }

    Future<void> sendPorClass() async {
      const url = 'https://sg.sdasystems.org/cms/cad_class_membro2.php';

      List bodyList = [];
      body.forEach((key, value) {
        bodyList.add('$key=$value');
      });
      List<int> cods = membros.map((e) => e.codUsuario).toList();
      bodyList.addAll(cods.map((i) => 'cod_usuario[]=$i').toList());

      bodyList.add('Submit=Salvar');
      bodyList.add('MM_insert=form1');

      for (var e in classes) {
        final cod = e.cod;
        bodyList.add('cod_classe=$cod');

        try {
          await post(url, body: bodyList);
        } catch(e) {
          _log.e('SgcProvider', 'enviarClasses', 'porMembro', porMembro, e);
        }

        bodyList.remove('cod_classe=$cod');
      }
    }

    if (porMembro) {
      await sendPorMembro();
    } else {
      await sendPorClass();
    }
  }


  Future<void> enviarMembro(Membro value, Map body, {FichaMedica? ficha, Map? bodyFicha}) async {
    var url = 'https://sg.sdasystems.org/cms/cad_usuario_clube.php';
    if (value.codUsuario != 0) {
      url = 'https://sg.sdasystems.org/cms/atualiza_usuario_clube.php';
      url += '?cod_usuario=${value.codUsuario}&seguro=1';
    }

    final res = await post(url, body: body..addAll(value.toJson()));

    final e = res.body.toLowerCase();
    if (e.contains('idade incompativel com a função')) {
      throw 'Idade incompativel com a função';
    }
    if (e.contains('cpf já existe')) {
      throw 'O CPF informado já está registrado';
    }

    if (value.codUsuario == 0) {
      final membrosList = await getMembrosList();

      for (var membro in membrosList) {
        if (membro.nomeUsuario == value.nomeUsuario) {
          value.codUsuario = membro.codUsuario;
        }
      }

      if (value.codUsuario == 0) throw 'codUsuario está vazio';
    }

    if (ficha != null) {
      bodyFicha!['cod_usuario'] = value.codUsuario;
      await enviarFicha(ficha, bodyFicha);
      value.fichaPendente = false;
    }

    membrosData[value.codUsuario] = value;

    notifyListeners();
  }

  Future<void> enviarFicha(FichaMedica value, Map body) async {
    final codUsuario = body['cod_usuario']!;
    if (value.codFicha == 0) {
      value.codFicha = (await getFichaMedica(codUsuario)).codFicha;
    }

    var url = 'https://sg.sdasystems.org/cms/ficha_usuario_clube.php';
    url += '?cod_usuario=$codUsuario';

    final res = await post(url, body: body..addAll(value.toJson()));

    final e = res.body;

    if (e.contains('')) {

    }
  }

  Future<void> enviarFoto(int codUser, Uint8List bytes, Map<String, String> body) async {
    final url = 'https://sg.sdasystems.org/cms/upload_foto.php?cod_usuario=$codUser';
    final res = await postFile(url, fileBytes: bytes, fileName: '$codUser.jpg', body: body);

    if (!res.body.contains('cadastrado com sucesso')) {
      throw res.body;
    }
  }

  Future<int?> enviarEvento(Evento value, Map<String, String> body) async {
    var url = 'https://sg.sdasystems.org/cms/cad_agenda_clube.php';
    url += '?dia=18&mes=08&ano=2024';

    body.addAll(value.toJson().map((key, value) => MapEntry(key, '$value')));
    await post(url, body: body);

    final eventos = await getEventos(value.from!.month, value.from!.year);

    bool verificarDados(Evento ev) {
      if (ev.nomeAgenda != value.nomeAgenda) return false;
      if (ev.dtAgenda != value.dtAgenda) return false;
      if (ev.dtAgendaFim != value.dtAgendaFim) return false;
      if (ev.codTipoAgenda != value.codTipoAgenda) return false;

      return true;
    }

    for (var ev in eventos) {
      if (verificarDados(ev)) return ev.codAgenda;
    }
    return null;
  }

  Future<void> enviarConta(PagamentoSgc conta, bool isReceita, List<Membro> membros, List<String> body) async {
    String path;
    String acao;
    String query = '';
    if (conta.codPagtoConta == 0) {
      acao = 'MM_insert=form1';
      path = isReceita ? 'cad_fin_areceber' : 'cad_fin_apagar';
      if (membros.isNotEmpty) {
        path += '2';
      } else {
        body.add('cod_membro=0');
      }
    } else {
      acao = 'MM_update=form1';
      path = isReceita ? 'atualiza_fin_areceber' : 'atualiza_fin_apagar';
      query = '?cod_pagto_conta=${conta.codPagtoConta}';
    }

    final url = 'https://sg.sdasystems.org/cms/$path.php$query';

    conta.toJson().forEach((key, value) {
      if (key == 'valor') {
        body.add('$key=${value.toString().replaceAll('.', ',')}');
      } else {
        body.add('$key=$value');
      }
    });

    body.addAll(membros.map((i) => 'cod_membro[]=${i.codUsuario}').toList());
    body.addAll(['Submit=Salvar', acao]);

    await post(url, body: body);
  }

  Future<void> setMembrosAtivo(List<int> codigos, bool ativo) async {
    const url = 'https://sg.sdasystems.org/cms/lista_usuario_clube.php';

    final body = [
      if (ativo)
        'Submit1=Ativar selecionados'
      else
        'Submit3=Inativar selecionadas',
    ];
    body.addAll(codigos.map((i) => 'usuario[]=$i').toList());
    final res = await post(url, body: body);

    if (!res.body.isNotEmpty) {
      throw res.body;
    }

    membrosData.removeWhere((key, vakue) => codigos.contains(key));
    notifyListeners();
    _saveLocalMembros(ativo);
  }

  Future<void> setContasPagas(List<int> codigos, bool isReceita, bool delete) async {
    final path = isReceita ? 'lista_fin_areceber' : 'lista_fin_apagar';
    final url = 'https://sg.sdasystems.org/cms/$path.php';

    final body = [
      if (delete)
        'Submit3=Excluir selecionadas'
      else
        'Submit1=Marcar como pago'
    ];
    body.addAll(codigos.map((i) => 'conta[]=$i').toList());
    final res = await post(url, body: body);

    if (!res.body.isNotEmpty) {
      throw res.body;
    }

  }


  Future<void> removeEspecialidadesMembro(int codEsp) async {
    var url = 'https://sg.sdasystems.org/cms/exclui_esp_membro.php';
    url += '?cod_us_esp=$codEsp';
    await post(url);
  }

  Future<void> removeClassesMembro(int codEsp) async {
    var url = 'https://sg.sdasystems.org/cms/exclui_classe_membro.php';
    url += '?cod_us_classe=$codEsp';
    await post(url);
  }

  Future<void> removeSeguro(int codUser, int codVida) async {
    var url = 'https://sg.sdasystems.org/cms/exclui_segurado_clube.php';
    url += '?cod_usuario=$codUser&cod_vida=$codVida';
    await post(url);
  }

  Future<void> removeEvento(int codEvento, int dia, int mes, int ano) async {
    var url = 'https://sg.sdasystems.org/cms/exclui_agenda_clube.php';
    url += '?&cod_agenda=$codEvento&dia=$dia&mes=$mes&ano=$ano';

    await post(url);
  }

  Future<void> removeConta(int codConta) async {
    final url = 'https://sg.sdasystems.org/cms/exclui_fin_apagar.php?cod_pagto_conta=$codConta';
    await post(url);
  }


  Future<void> removeUnidade(int codUnidade) async {
    final url = 'https://sg.sdasystems.org/cms/exclui_unidade.php?cod_unidade=$codUnidade';
    await post(url);
  }

  Future<void> removeUnidadeMembros(List<int> cods) async {
    const url = 'https://sg.sdasystems.org/cms/lista_un_membros.php';
    final body = [
      'Submit1=Excluir selecionados'
    ];
    body.addAll(cods.map((i) => 'usuario[]=$i').toList());
    await post(url, body: body);
  }



  //endregion


  //region login

  Future<void> login(String usuario, String senha, {bool tryAgain = true}) async {
    final body = {
      'login': usuario,
      'senha': senha,
      'Submit': 'Entrar',
    };

    final res = await post('https://sg.sdasystems.org/cms/login.php?lang=pt_br', body: body);

    if (res.body.contains('Usuário não encontrado')) {
      throw 'Usuário não encontrado\n$body';
    }

    _token = res.headers['set-cookie'] ?? '';

    if (_token.isEmpty && tryAgain) {
      return await login(usuario, senha, tryAgain: false);
    }
    _log.d('login', ['token', _token]);
    notifyListeners();
  }

  Future<void> relogin() async {
    final email = pref.getString(PrefKey.userLogin);
    final senha = pref.getString(PrefKey.userSenha);

    await login(email, senha);
  }

  //endregion

  //region post

  Future<http.Response> post(String url, {dynamic body, bool tryAgain = true}) async {
    verificarInternet();

    List<String>? enc = [];
    if (body is Map) {
      body.forEach((key, value) {
        enc!.add('$key=$value');
      });
    } else if (body is List) {
      for (var value in body) {
        enc.add(Uri.encodeComponent(value.toString()).replaceAll('%3D', '='));
      }
    } else if (body is String) {
      enc.add(body);
    }

    if (enc.isEmpty) enc = null;

    final res = await http.post(Uri.parse(url),
      body: enc?.join('&'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Cookie': _token,
      },
      encoding: latin1,
    );

    if (res.body.contains('Your session has expired')) {
      await relogin();
      return await post(url, body: body, tryAgain: false);
    }

    if (res.statusCode != 200 && res.statusCode != 302) {
      throw {
        'statusCode': res.statusCode,
        'body': res.body,
      };
    }

    return res;
  }

  Future<http.Response> postFile(String url, {required Uint8List fileBytes, String? fileName, Map<String, String>? body, bool tryAgain = true}) async {
    verificarInternet();

    var request = http.MultipartRequest('POST', Uri.parse(url));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Cookie': _token,
    });
    if (body != null) request.fields.addAll(body);

    final fileData = http.MultipartFile.fromBytes(
      'arquivo', fileBytes,
      filename: fileName,
    );
    request.files.add(fileData);

    http.Response? res = await http.Response.fromStream(await request.send());

    if (res.body.contains('Acesso inválido') && tryAgain) {
      await relogin();
      return postFile(url, fileBytes: fileBytes, fileName: fileName, body: body, tryAgain: false);
    }

    return res;
  }

  //endregion

  //region local data

  List<Membro> queryMembros(String query) {
    query = Util.toQuery(query);
    List<Membro> items = [];
    for (var item in membros) {
      final textQuery = Util.toQuery(item.nomeUsuario);
      if (textQuery.contains(query)) {
        items.add(item);
      }
    }
    return items;
  }

  @override
  void loadLocal() {}

  @override
  void saveLocal() {}

  void _saveLocalMembros(bool desativados) {
    final child = desativados ? 'sgc_membros_desativados' : 'sgc_membros';
    database.child(child)
        .set(Util.mapObjectToJson(membrosData));
  }

  // void _saveLocalEspecialidades() {
  //   database.child('sgc_especialidades')
  //       .set(Util.mapObjectToJson(especialidadesData));
  // }


  void loadLocalMembros(bool desativados) {
    try {
      final child = desativados ? 'sgc_membros_desativados' : 'sgc_membros';
      final res = database.child(child).get(def: {});
      final map = Membro.fromJsonList(res.value);

      membrosData.clear();
      map.forEach((key, value) {
        membrosData[int.parse(key)] = value;
      });
      notifyListeners();
    } catch(e) {
      _log.e('loadLocalMembros', e);
    }
  }

  // void loadLocalEspecialidades() {
  //   try {
  //     final res = database.child('sgc_especialidades').get(def: {});
  //
  //     especialidadesData.addAll(Especialidade.fromJsonList(res.value));
  //     notifyListeners();
  //   } catch(e) {
  //     log.e('loadLocalEspecialidades', e);
  //   }
  // }


  Map<String, dynamic> _mapFromResponse(String res) {
    final doc = html.Document.html(res);
    final inputs = doc.getElementsByTagName('input');
    final textareas = doc.getElementsByTagName('textarea');
    final selects = doc.getElementsByTagName('select');

    Map<String, dynamic> dados = {};

    for (var i in inputs) {
      if (!i.attributes.containsKey('name')) continue;

      final key = i.attributes['name']!;
      final value = i.attributes['value'] ?? '';

      if (i.attributes['type'] == 'radio') {
        if (i.attributes.containsKey('checked')) {
          dados[key] = value;
        }
        continue;
      }

      if (i.attributes['type'] == 'checkbox') {
        dados[key] = i.attributes.containsKey('checked');
        continue;
      }

      if (key.contains('cod')) {
        dados[key] = int.tryParse(value) ?? 0;
      } else {
        dados[key] = value.toUpperCase();
      }
    }

    for (var i in textareas) {
      if (!i.attributes.containsKey('name')) continue;

      dados[i.attributes['name']!] = i.text.trimLeft().trimRight().toUpperCase();
    }

    for (var i in selects) {
      if (!i.attributes.containsKey('name')) continue;

      final options = i.getElementsByTagName('option');

      for (var o in options) {
        if (o.attributes.containsKey('selected')) {
          final value = o.attributes['value'] ?? '';
          dados[i.attributes['name']!] = int.tryParse(value) ?? value.toUpperCase();
          break;
        }
      }
    }

    return dados;
  }

  @override
  Future<void> close() async {
    _token = '';
    membrosData.clear();
    _membrosLoaded = false;
  }

  //endregion

}

class SgcLoginAction {
  static const membro = 6532168;
  static const especialidades = 9864532;
}