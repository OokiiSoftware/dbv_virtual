import 'package:flutter/material.dart';
import '../../../provider/provider.dart';
import '../../../util/util.dart';
import '../../page.dart';

class AreaDbvPage extends StatefulWidget {
  const AreaDbvPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<AreaDbvPage> {

  bool get readOnly => FirebaseProvider.i.readOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Área do Desbravador'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: _onVotoLemaTap,
            leading: const Icon(Icons.front_hand),
            title: const Text('IDEAIS'),
            subtitle: const Text('Voto, Lema, Ideais, etc..'),
          ),
          ListTile(
            onTap: _onHinosTap,
            leading: const Icon(Icons.music_note),
            title: const Text('HINOS'),
            subtitle: const Text('Clube, Desbravador, Nacional, etc..'),
          ),
          ListTile(
            onTap: _onEspecialidadesTap,
            leading: const Icon(Icons.local_fire_department),
            title: const Text('ESPECIALIDADES'),
            subtitle: const Text('Adra, Artes, Natureza, etc..'),
          ),
          ListTile(
            onTap: _onManuaisTap,
            leading: const Icon(Icons.edit_note),
            title: const Text('GUIAS E MANUAIS'),
            subtitle: const Text('Administrativo, Aspirante, Nós e amarras, etc..'),
          ),
          // ListTile(
          //   onTap: _onUniformesTap,
          //   leading: const Icon(Icons.person),
          //   title: const Text('UNIFORMES'),
          //   subtitle: const Text('Gala, Campo, etc..'),
          // ),
        ],
      ),
    );
  }

  void _onVotoLemaTap() {
    Navigate.push(context, const VotoLemaPage());
  }

  void _onHinosTap() {
    Navigate.push(context, const HinosPage());
  }

  void _onManuaisTap() {
    Navigate.push(context, ManuaisPage(readOnly: readOnly));
  }

  void _onEspecialidadesTap() {
    Navigate.push(context, EspecialidadeAreasPage(readOnly: readOnly));
  }

  // void _onUniformesTap() {
  //   Log.snack('Disponível em breve', isError: true);
  // }
}

class VotoLemaPage extends StatelessWidget {
  const VotoLemaPage({super.key});

  final String voto = '''
Pela graça de Deus,
Serei puro, bondoso e leal;
Guardarei a lei do Desbravador,
Serei servo de Deus e amigo de todos.
  ''';

  final String lei = '''
A lei do Desbravador ordena-me:

Observar a devoção matinal,
Cumprir fielmente a parte que me corresponde,
Cuidar de meu corpo,
Manter a consciência limpa,
Ser cortês e obediente,
Andar com reverência na casa de Deus,
Ter sempre um cântico no coração,
Ir aonde Deus mandar.
  ''';

  final String alvo = '''
A mensagem do advento a
todo o mundo na minha geração.
  ''';

  final String lema = '''
O amor de Cristo me motiva.
  ''';

  final String objetivo = '''
Salvar do pecado e guiar no serviço.
  ''';

  final String votoBiblia = '''
Prometo fidelidade à Bíblia,
À sua mensagem, de um Salvador crucificado ressurreto e prestes a vir,
Doador de vida e liberdade a todos que nEle crêem.
  ''';

  @override
  Widget build(BuildContext context) {
    Widget bloco(String title, String body) {
      return Card(
        child: Column(
          children: [
            Text(title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(body,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ideais do Desbravador'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          bloco('VOTO', voto),
          bloco('Lei', lei),
          bloco('Alvo', alvo),
          bloco('Lema', lema),
          bloco('Objetivo', objetivo),
          bloco('Voto de Fidelidade à Bíblia', votoBiblia),
        ],
      ),
    );
  }
}