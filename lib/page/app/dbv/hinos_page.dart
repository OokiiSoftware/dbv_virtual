import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../model/model.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class HinosPage extends StatefulWidget {
  const HinosPage({super.key});

  @override
  State<StatefulWidget> createState() => _StateHinosPage();
}
class _StateHinosPage extends State<HinosPage> with SingleTickerProviderStateMixin {

  late final TabController _tabController = TabController(length: 3, vsync: this);

  static bool _playerIniciado = false;
  static final player = AudioPlayer();

  bool get playng => player.state == PlayerState.playing;

  static Duration? _positionTemp;
  static Duration _duration = Duration.zero;
  static Hino _currentHino = Hino();

  Hino _hinoClube = Hino();
  Hino _hinoDbv = Hino();
  Hino _hinoNac = Hino();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    Widget page(Hino audio, [bool hinoClubeVazio = false]) {
      return SubPage(
        hino: audio,
        onPlayTap: _play,
        onSaveFileTap: _saveFile,
        onClubeConfigTap: _onConfigTap,
        hinoClubeVazio: hinoClubeVazio,
        playng: _currentHino == audio && playng,
      );
    }

    String durationConvert(Duration value) {
      final s = value.toString();
      return s.substring(0, s.indexOf('.'));
    }

    final readOnly = FirebaseProvider.i.readOnly;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hinos'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Clube'),
            Tab(text: 'Desbravador'),
            Tab(text: 'Nacional'),
          ],
        ),
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _currentHino.url.isEmpty ? 0 : 50,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black38,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: player.onPositionChanged,
                    builder: (context, snapshot) {
                      try {
                        final pos = snapshot.data ?? Duration.zero;

                        return Stack(
                          children: [
                            Positioned(
                              left: 20,
                              bottom: 0,
                              child: Text(durationConvert(_positionTemp ?? pos)),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 0,
                              child: Text(durationConvert(_duration)),
                            ),

                            Slider(
                              value: (_positionTemp ?? pos).inMilliseconds.toDouble(),
                              max: _duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                _positionTemp = Duration(milliseconds: value.toInt());
                                _setState();
                              },
                              onChangeStart: (value) {
                                _positionTemp = Duration(milliseconds: value.toInt());
                                _setState();
                              },
                              onChangeEnd: (value) async {
                                await player.seek(Duration(milliseconds: value.toInt()));
                                _positionTemp = null;
                                _setState();
                              },
                            ),
                          ],
                        );
                      } catch(e) {
                        return Stack(
                          children: [
                            Positioned(
                              left: 20,
                              bottom: 0,
                              child: Text(durationConvert(const Duration())),
                            ),
                            Positioned(
                              right: 20,
                              bottom: 0,
                              child: Text(durationConvert(_duration)),
                            ),

                            Slider(
                              value: 0,
                              max: 1,
                              onChanged: (value) {
                                _positionTemp = Duration(milliseconds: value.toInt());
                                _setState();
                              },
                              onChangeStart: (value) {
                                _positionTemp = Duration(milliseconds: value.toInt());
                                _setState();
                              },
                              onChangeEnd: (value) async {
                                await player.seek(Duration(milliseconds: value.toInt()));
                                _positionTemp = null;
                                _setState();
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),

                IconButton(
                  onPressed: () => _play(_currentHino),
                  icon: Icon(playng ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),  // aurio player

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                page(_hinoClube, _hinoClube.letra.isEmpty && !readOnly),
                page(_hinoDbv),
                page(_hinoNac),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _init() async {
    if (!_playerIniciado) {
      player.onPlayerComplete.listen((event) {
        player.pause();
        _setState();
      });

      _playerIniciado = true;
    }
    final hinoDbvFile = StorageProvider.i.file(['audios', 'hinoDbv.mp3']);
    final hinoNacFile = StorageProvider.i.file(['audios', 'hinoNacional.m4a']);

    final hinoDbvBaixado = await hinoDbvFile.exists();
    final hinoNacBaixado = await hinoNacFile.exists();

    final clube = ClubeProvider.i.clube;

    _hinoClube = Hino(
      titulo: 'Hino do Clube ${clube.nome}',
      letra: clube.hino,
    );
    _hinoDbv = Hino(
      titulo: 'Hino dos Desbravadores',
      url: 'https://firebasestorage.googleapis.com/v0/b/dbv-virtual.appspot.com/o/app%2Ffiles%2Fhino%20dos%20desbravadores.mp3?alt=media&token=8e198252-583f-4407-b63f-6ef6549c2cc1',
      letra: _hinoDesbravadores,
      baixado: hinoDbvBaixado,
      file: hinoDbvFile,
    );
    _hinoNac = Hino(
      titulo: 'Hino Nacional',
      url: 'https://firebasestorage.googleapis.com/v0/b/dbv-virtual.appspot.com/o/app%2Ffiles%2Fhino%20nacional.m4a?alt=media&token=564c1605-28a8-4d93-9ccf-471d0d0b835d',
      letra: _hinoNacional,
      baixado: hinoNacBaixado,
      file: hinoNacFile,
    );

    _setState();
  }

  void _play(Hino audio) async {
    if (playng && (_currentHino == audio)) {
      await player.pause();
      _setState();
      return;
    }

    if (audio.baixado) {
      await player.play(DeviceFileSource(audio.file!.path));
    } else {
      if (InternetProvider.i.disconnected) {
        InternetProvider.showMsgNoConnect();
        return;
      }

      await player.play(UrlSource(audio.url));
    }

    final dur = await player.getDuration();

    _currentHino = audio;

    _duration = dur ?? Duration.zero;
    _setState();
  }

  void _onConfigTap() async {
    final clube = ClubeProvider.i.clube;
    final res = await Navigate.push(context, HinoPage(hino: clube.hino));
    if (res is String) {
      clube.hino = res;
      _hinoClube.letra = res;
      _setState();
    }
  }


  void _saveFile(Hino value) async {
    if (InternetProvider.i.disconnected) {
      InternetProvider.showMsgNoConnect();
      return;
    }

    try {
      value.baixando = true;
      _setState();

      await StorageProvider.i.createFolder('audios');

      final dio = Dio();

      final res = await dio.get(value.url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        onReceiveProgress: (a, b) {
          value.downloadProgress(a, b);
          _setState();
        },
      );

      await value.file!.writeAsBytes(res.data);

      Log.snack('Arquivo baixado');

      value.baixado = true;
    } catch(e) {
      Log.snack('Não foi possível baixar o arquivo', isError: true,
          actionClick: !mounted ? null : () {
            Popup(context).errorDetalhes(e);
          });
    }
    value.baixando = false;
    _setState();
  }

  void _setState() {
    setState(() {});
  }


  final _hinoNacional = '''
PARTE I

Ouviram do Ipiranga as margens plácidas
De um povo heróico o brado retumbante,
E o sol da liberdade, em raios fúlgidos,
Brilhou no céu da pátria nesse instante.

Se o penhor dessa igualdade
Conseguimos conquistar com braço forte,
Em teu seio, ó liberdade,
Desafia o nosso peito a própria morte!

Ó Pátria amada,
Idolatrada,
Salve! Salve!

Brasil, um sonho intenso, um raio vívido
De amor e de esperança à terra desce,
Se em teu formoso céu, risonho e límpido,
A imagem do Cruzeiro resplandece.

Gigante pela própria natureza,
És belo, és forte, impávido colosso,
E o teu futuro espelha essa grandeza.
Terra adorada,

Entre outras mil,
És tu, Brasil,
Ó Pátria amada!

Dos filhos deste solo és mãe gentil,
Pátria amada,
Brasil!


PARTE II

Deitado eternamente em berço esplêndido,
Ao som do mar e à luz do céu profundo,
Fulguras, ó Brasil, florão da América,
Iluminado ao sol do Novo Mundo!

Do que a terra, mais garrida,
Teus risonhos, lindos campos têm mais flores;
"Nossos bosques têm mais vida",
"Nossa vida" no teu seio "mais amores."

Ó Pátria amada,
Idolatrada,
Salve! Salve!

Brasil, de amor eterno seja símbolo
O lábaro que ostentas estrelado,
E diga o verde-louro dessa flâmula
"Paz no futuro e glória no passado."

Mas, se ergues da justiça a clava forte,
Verás que um filho teu não foge à luta,
Nem teme, quem te adora, a própria morte.
Terra adorada,

Entre outras mil,
És tu, Brasil,
Ó Pátria amada!
Dos filhos deste solo és mãe gentil,
Pátria amada,
Brasil!''';

  final _hinoDesbravadores = '''
Nós somos os Desbravadores
Os servos do Rei dos reis

Sempre avante assim marchamos
Fiéis às Suas leis.

Devemos ao mundo anunciar
As novas da salvação

Que Cristo virá em breve dar o galardão''';

}

class SubPage extends StatelessWidget {
  final Hino hino;
  final bool playng;
  final bool hinoClubeVazio;
  final void Function(Hino)? onSaveFileTap;
  final void Function(Hino)? onPlayTap;
  final void Function()? onClubeConfigTap;
  const SubPage({
    super.key,
    required this.hino,
    this.onSaveFileTap,
    this.onClubeConfigTap,
    this.onPlayTap,
    this.playng = false,
    this.hinoClubeVazio = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (hino.baixando)
              LinearProgressIndicator(value: hino.progress,),

            const Row(),

            Text(hino.titulo,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            Text(hino.letra,
              textAlign: TextAlign.center,
            ),

            if (hinoClubeVazio)...[
              const Text('O Hino do seu clube não foi informado'),
              const Text('Para enviar o Hino vá para as'),
              const Text('configurações do clube'),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: onClubeConfigTap,
                child: const Text('Ir Para a configuração'),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: hino.url.isEmpty ? null : Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'yuuiiojjniu$hashCode',
              onPressed: () => onPlayTap?.call(hino),
              child: Icon(playng ? Icons.pause : Icons.play_arrow),
            ),

            const SizedBox(height: 10),

            if (!hino.baixado && !hino.baixando)
              FloatingActionButton(
                heroTag: 'iuirgnvorbr$hashCode',
                tooltip: 'Baixar',
                onPressed: () => onSaveFileTap?.call(hino),
                child: const Icon(Icons.download),
              ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}