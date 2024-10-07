import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../res/res.dart';
import '../../../util/util.dart';
import '../../page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _State();
}
class _State extends State<MainPage> {

  FirebaseProvider _fireProv = FirebaseProvider.i;
  ClubeProvider _clubeProvider = ClubeProvider.i;

  @override
  Widget build(BuildContext context) {
    var solicitacaoAlteracaoMembro = context.watch<EditMembrosProvider>().list.isNotEmpty;
    var solicitacaoEspecialidades = context.watch<EditEspecialidadesProvider>().list.isNotEmpty;

    final media = MediaQuery.of(context);
    final size = media.size;

    _clubeProvider = context.watch<ClubeProvider>();
    _fireProv = context.watch<FirebaseProvider>();
    final clube = _clubeProvider.clube;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black,
                    Tema.i.primaryColor,
                    Tema.i.primaryColor,
                    // Tema.i.primaryColorLight,
                  ],
                ),
              ),
            ), // background

            _mainMenu(),  // menu

            _stars(),

            Positioned(
              top: 50,
              left: 20,
              width: size.width - 40,
              child: Row(
                children: [
                  Expanded(
                    child: Text(clube.nome,
                      style: TextStyle(
                        fontFamily: 'Bkdbd',
                        fontSize: 50,
                        color: Tema.i.tintDecColor,
                        shadows: const [
                          BoxShadow(
                            color: Colors.white,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Tema.i.tintDecColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Tema.i.primaryColor,
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: _onPerfilTap,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 100,
                              width: 100,
                              child: FotoLayout(
                                path: _fireProv.user.foto,
                                erroIcon: const Icon(Icons.person,
                                  color: Colors.black,
                                  size: 30,
                                ),
                              ),
                            ),

                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.only(bottom: 5),
                                child: const Text('Meu Perfil',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w100,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),  // title & foto

            Positioned(
              right: 15,
              bottom: 5,
              child: Text('v ${VersionControlProvider.i.version}'),
            ),

            if (!_fireProv.readOnly)
              Positioned(
                bottom: 30,
                left: 60,
                right: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (solicitacaoAlteracaoMembro)...[
                      ElevatedButton(
                        onPressed: () => _onSgcTap(SgcLoginAction.membro),
                        child: const Text('Solicitação de Alteração de Membro',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],

                    if (solicitacaoEspecialidades)...[
                      ElevatedButton(
                        onPressed: () => _onSgcTap(SgcLoginAction.especialidades),
                        child: const Text('Solicitação para add Especialidades',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mainMenu() {
    final media = MediaQuery.of(context);
    final portrtait = media.orientation == Orientation.portrait;
    final size = media.size;

    final clube = _clubeProvider.clube;

    var padding = EdgeInsets.only(
      left: portrtait ? 0 : 50,
      right: portrtait ? 0 : 50,
      top: portrtait ? 140 : 0,
      bottom: portrtait ? 40 : 0,
    );

    double getMenuItemSize() {
      if (portrtait) {
        return size.width / 2.7;
      }
      return size.height / 3;
    }

    final menuItemSize = getMenuItemSize();
    final tileSpace = menuItemSize / 2;

    final topBasePos = portrtait ? 0 : (size.height / 2.5);
    final midBasePos = portrtait ? (size.width / 2 - tileSpace) : 0;

    double getTopPos(double line) => topBasePos + (line * tileSpace);
    double getSidePos(double line) => midBasePos + (line * tileSpace);

    Offset positionByIndex(int i) {
      switch(i) {
        case 0: return const Offset(0, 0);
        case 1: return const Offset(1, -1);
        case 2: return const Offset(1, 1);
        case 3: return const Offset(2, 0);
        case 4: return const Offset(3, -1);
        case 5: return const Offset(3, 1);
        case 6: return const Offset(4, 0);
        case 7: return const Offset(5, -1);
        case 8: return const Offset(5, 1);
        case 9: return const Offset(6, 0);
        case 10: return const Offset(7, -1);
        case 11: return const Offset(7, 1);
        case 12: return const Offset(8, 0);
        case 13: return const Offset(9, -1);
        case 14: return const Offset(9, 1);
        case 15: return const Offset(10, 0);
        case 16: return const Offset(11, -1);
        case 17: return const Offset(11, 1);
        default: return Offset.zero;
      }
    }

    List<Widget> menuItems = [
      MainPageMenuItem(
        image: FotoLayout(
          path: clube.logoUrl,
          saveTo: Ressorces.clubeLogo,
          backgroundColor: Colors.transparent,
          borderRadius: 0,
          headers: FirebaseProvider.i.headers,
          erroIcon: Image.asset(Assets.clubeLogo),
        ),
        onTap: _onClubeTap,
        size: menuItemSize,
      ),  // Clube

      MainPageMenuItem(
        icon: Icons.group,
        title: 'Membros',
        onTap: _onMembrosTap,
        size: menuItemSize,
      ),  // Membros
      MainPageMenuItem(
        icon: Icons.calendar_month,
        title: 'Agenda',
        onTap: _onAgendaTap,
        size: menuItemSize,
      ),  // Agenda

      MainPageMenuItem(
        icon: Icons.local_library,
        title: 'Biblioteca',
        onTap: _onBibliotecaTap,
        size: menuItemSize,
      ),  // Biblioteca

      MainPageMenuItem(
        icon: Icons.shield,
        title: 'DBV',
        onTap: _onDbvAreaTap,
        size: menuItemSize,
      ),  // DBV

      if (!_fireProv.readOnly)
        MainPageMenuItem(
          icon: Icons.warning,
          title: 'Advertencias',
          onTap: _onAdvertenciasTap,
          size: menuItemSize,
        ),  // Advertencias

      MainPageMenuItem(
        icon: Icons.edit_document,
        title: 'Regulamento',
        onTap: _onRegulamentoTap,
        size: menuItemSize,
      ),  // Regulamento

      MainPageMenuItem(
        icon: Icons.group_off,
        title: 'Faltas',
        onTap: _onFaltasTap,
        size: menuItemSize,
      ),  // Faltas
      MainPageMenuItem(
        icon: Icons.payment,
        title: 'Pagamento Mensal',
        onTap: _onPagamentosTap,
        size: menuItemSize,
      ),  // Pagamentos

      if (!_fireProv.readOnly)
        MainPageMenuItem(
          icon: Icons.system_security_update,
          title: 'SGC',
          onTap: _onSgcTap,
          size: menuItemSize,
        ),  // SGC

      if (debugMode)
        MainPageMenuItem(
          icon: Icons.bakery_dining_rounded,
          title: 'Master',
          onTap: _onDebugTap,
          size: menuItemSize,
        ),  // SGC
    ];

    double meno = 0.5;
    int cont = 0;
    for (var _ in menuItems) {
      cont++;
      if (cont == 3) {
        cont = 0;
        continue;
      }
      meno += .5;
    }

    final menuContainerSize = meno * menuItemSize;
    final height = portrtait ? menuContainerSize : size.height;
    final width = portrtait ? size.width : menuContainerSize;
    final totalHeight = menuContainerSize + padding.top;

    bool telaGrande() {
      if (portrtait) {
        return totalHeight < size.height;
      }

      return menuContainerSize < size.width;
    }

    if (telaGrande()) {
      padding = EdgeInsets.zero;
    }

    final child = SingleChildScrollView(
      scrollDirection: portrtait ? Axis.vertical : Axis.horizontal,
      padding: padding,
      child: SizedBox(
        height: height,
        width: width,
        child: Stack(
          children: [
            for(int i = 0; i < menuItems.length; i++)
              Builder(
                builder: (context) {
                  final pos = positionByIndex(i);
                  final x = portrtait ? pos.dx : pos.dy;
                  final y = portrtait ? pos.dy : pos.dx;

                  return Positioned(
                    top: getTopPos(x),
                    left: getSidePos(y),
                    child: menuItems[i],
                  );
                },
              ),
          ],
        ),
      ),
    );

    if (telaGrande()) {
      return Positioned(
        top: portrtait ? (size.height / 2) - ((menuContainerSize - 140) / 2) : 0,
        left: portrtait ? 0 : (size.width / 2) - (menuContainerSize / 2),
        width: size.width,
        height: size.height,
        child: child,
      );
    }

    return child;
  }

  Widget _stars() {
    var starsCount = context.watch<CvProvider>().starsCount;

    Color color(int number) {
      if (number <= starsCount) {
        return Colors.yellow;
      }
      return Colors.grey;
    }

    Icon icon(int number) {
      return Icon(Icons.star,
        size: 30,
        color: color(number),
        shadows: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: [
          const Spacer(flex: 3),

          ...[5, 4, 3, 2, 1].map((i) => Expanded(child: icon(i))),

          const Spacer(flex: 2),
        ],
      ),
    );
  }


  void _onPerfilTap() {
    Navigate.push(context, PerfilPage(
      membro: FirebaseProvider.i.user,
    ));
  }

  void _onClubeTap() {
    Navigate.push(context, const ClubePage());
  }
  void _onMembrosTap() {
    Navigate.push(context, const MembrosPage2());
  }
  void _onAgendaTap() {
    Navigate.push(context, const AgendaPage());
  }
  void _onFaltasTap() {
    Navigate.push(context, const FaltasPage2());
  }
  void _onAdvertenciasTap() async {
    if (FirebaseProvider.i.readOnly) {
      DialogBox(
        context: context,
        title: 'Ops',
        content: [
          const Text('Você não tem pesmissão para acessar estas informações'),
        ],
      ).ok();
      return;
    }

    Navigate.push(context, const AdvertenciasPage2());
  }
  void _onRegulamentoTap() {
    final clube = ClubeProvider.i.clube;

    if (clube.regulamentoInterno.isEmpty) {
      Log.snack('O regulamento não foi informado');
      return;
    }

    Navigate.push(context, PdfViewPage(
      title: 'Regulamento',
      pdfUrl: clube.regulamentoInterno,
    ));
  }
  void _onPagamentosTap() {
    Navigate.push(context, const PagamentosPage2());
  }
  void _onSgcTap([int? action]) {
    Navigate.push(context, SgcPage(loginAction: action));
  }
  void _onDebugTap() {
    Navigate.push(context, const DebugPage());
  }

  void _onBibliotecaTap() {
    Navigate.push(context, LivrariaPage(
      readOnly: FirebaseProvider.i.readOnly,
    ));
  }
  void _onDbvAreaTap() {
    Navigate.push(context, const AreaDbvPage());
  }

}

class MainPageMenuItem extends StatelessWidget {
  final String? title;
  final double size;
  final Widget? image;
  final IconData? icon;
  final void Function()? onTap;
  const MainPageMenuItem({
    super.key,
    this.title,
    this.onTap,
    this.icon,
    this.image,
    this.size = 94,
  });

  @override
  Widget build(BuildContext context) {
    final sizeContainer = size - 70;
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size / 6.5),
      child: Transform.rotate(
        angle: 0.79,
        child: Container(
          decoration: BoxDecoration(
            color: Tema.i.primaryColor,
            boxShadow: const [
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
              ),
            ],
          ),
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Transform.rotate(
                angle: -0.79,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (image != null)
                      Container(
                        width: sizeContainer,
                        height: sizeContainer,
                        alignment: Alignment.center,
                        child: image!,
                      )
                    else if (icon != null)
                        Icon(icon,
                          color: Tema.i.tintDecColor,
                        ),

                    if (title != null)
                      Text(title!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Tema.i.tintDecColor),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}