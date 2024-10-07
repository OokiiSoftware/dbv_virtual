import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class ClubePage extends StatefulWidget {
  const ClubePage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<ClubePage> {

  static final List<Content> _chatDef = [];
  static final List<Content> _chat = [];

  late final _Interact _interact;

  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final _interactKey = 'interact';
  final _gemini = Gemini.instance;
  final _focus = FocusNode();

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    // _chatDef.clear();
    // pref.remove(_interactKey);
    _interact = _Interact.fromJson(pref.getObject(_interactKey));
    _interact.tryReset();

    if (_chatDef.isNotEmpty) return;
    final clube = ClubeProvider.i.clube;

    _chatDef.addAll([
      Content(
        parts: [Parts(text: 'Quem são vocês?')],
        role: 'user',
      ),
      Content(
        parts: [Parts(text: 'Somos um clube de desbravadores')],
        role: 'model',
      ),

      Content(
        parts: [Parts(text: 'Qual o seu nome?')],
        role: 'user',
      ),
      Content(
        parts: [Parts(text: 'Meu nome é ${clube.nome}')],
        role: 'model',
      ),

      Content(
        parts: [Parts(text: 'Legal, de onde vocês são?')],
        role: 'user',
      ),
      Content(
        parts: [
          // Parts(text: 'Eu sou de Governador Archer no Maranhão'),
          Parts(text: 'Somos da Associação ${clube.associacao}'),
          Parts(text: 'Na região ${clube.regiao}'),
        ],
        role: 'model',
      ),

      Content(
        parts: [Parts(text: 'Hmm.. Desde quando?')],
        role: 'user',
      ),
      Content(
        parts: [
          Parts(text: 'Fomos fundados em ${clube.dataFundacao}'),
          // Parts(text: 'Criado por Jackson Cielme'),
        ],
        role: 'model',
      ),

      Content(
        parts: [Parts(text: 'Ah, e quando tem reuniões?')],
        role: 'user',
      ),
      Content(
        parts: [
          Parts(text: 'Nos reunimos ${clube.reuniaoDia}'),
          Parts(text: 'Às ${clube.reuniaoHora}h'),
        ],
        role: 'model',
      ),
      Content(
        parts: [Parts(text: 'Gostei')],
        role: 'user',
      ),
      Content(
        parts: [
          Parts(text: 'Fique a vontade pra me perguntar qualquer coisa, estou aqui pra te ajudar'),
          Parts(text: 'Mas lembre-se que você só pode fazer ${_Interact.maxInteract} perguntas por dia'),
        ],
        role: 'model',
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final clube = context.watch<ClubeProvider>().clube;

    Widget block(String text, bool right) {
      return Align(
        alignment: right ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 5, 20, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: right ? Tema.i.tintDecColor : Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableText(text.replaceAll('**', ''),
            style: TextStyle(
              color: right ? Colors.white : Tema.i.tintDecColor,
            ),
          ),
        ),
      );
    }

    Widget block2(Content content) {
      bool right = content.role == 'user';
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for(var part in content.parts!)
            block(part.text!, right),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Tema.i.primaryColor,
      appBar: AppBar(
        title: Text(clube.nome),
        actions: [
          IconButton(
            tooltip: 'Limpar conversa',
            onPressed: _onCleanDialog,
            icon: const Icon(Icons.chat),
          ),

          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: FotoLayout(
                      path: clube.logoUrl,
                      width: 200,
                      borderRadius: 10,
                      backgroundColor: Colors.transparent,
                      saveTo: Ressorces.clubeLogo,
                      headers: FirebaseProvider.i.headers,
                      erroIcon: Image.asset(Assets.clubeLogo),
                    ),
                  ),  // logo

                  const SizedBox(height: 10),

                  for(var content in _chatDef + _chat)
                    block2(content),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text('Interações de hoje: ${_interact.count}/${_Interact.maxInteract}',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // for(var text in _dialogs)
                  //   block(text, true, 2),
                ],
              ),
            ),
          ),

          if (_inProgress)
            const LinearProgressIndicator(),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    focusNode: _focus,
                    onFieldSubmitted: _onSendTap,
                    decoration: const InputDecoration(
                      hintText: 'Digite aqui..',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _onSendTap,
                  icon: const Icon(Icons.send),
                ),

                if (!FirebaseProvider.i.readOnly)
                  IconButton(
                    tooltip: 'Configurações',
                    onPressed: _onEditTap,
                    icon: const Icon(Icons.settings),
                  ),
              ],
            ),
          ),  // digitar
        ],
      ),
    );
  }

  void _onSendTap([String? value]) async {
    if (_interact.count >= _Interact.maxInteract) {
      Log.snack('Interação exedida', isError: true, actionClick: () {
        DialogBox(
          context: context,
          content: [
            const Text('Você já usou todas as suas ${_Interact.maxInteract} interações de hoje.'),
          ],
        ).ok();
      });
      return;
    }

    final text = _textController.text.trimLeft().trimRight();
    if (text.isEmpty) return;

    _textController.text = '';
    _chat.add(Content(
      parts: [Parts(text: text)],
      role: 'user',
    ));

    await Future.delayed(const Duration(milliseconds: 100));
    _setState();
    _animScroll();

    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    _setInProgress(true);

    await _responder();
    if (kReleaseMode) {
      _addInteracao();
    }

    _focus.requestFocus();
    _setInProgress(false);
  }

  Future<void> _responder() async {
    // await Future.delayed(Duration(seconds: 2)); return;
    final res = await _gemini.chat(_chat);
    final content = res?.content;

    if (content != null) {
      _chat.add(content);
    }

    _animScroll();
  }


  void _animScroll() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.bounceIn,
    );
  }

  void _onCleanDialog() async {
    final res = await DialogBox(
      context: context,
      title: 'limpar conversa',
      content: const [
        Text('As informações do clube serão mantidas.'),
        Text('Deseja prosseguir?'),
      ],
    ).simNao();
    if (!res.isPositive) return;

    _chat.clear();
    _setState();
  }

  void _onEditTap() {
    Navigate.push(context, ClubeEditPage(
      clube: ClubeProvider.i.clube.copy(),
      readOnly: false,
    ));
  }

  void _addInteracao() {
    _interact.count++;
    pref.setObject(_interactKey, _interact.toJson());
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

class _Interact {

  static const int maxInteract = 3;

   String _data = '';
   String get data => _data;

   int count = 0;

  _Interact.fromJson(Map? map) :
        _data = map?['data'] ?? Formats.data(DateTime.now()),
        count = map?['count'] ?? 0;

  Map<String, dynamic> toJson() => {
    'data': data,
    'count': count,
  };

  void tryReset() {
    final date = Formats.stringToDateTime(data);
    if (date == null) {
      count = 0;
      return;
    }

    final velho = Formats.data(date);
    final novo = Formats.data(DateTime.now());

    if (novo.compareTo(velho) > 0) {
      _data = novo;
      count = 0;
    }
  }
}