import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'provider/provider.dart';
import 'page/page.dart';
import 'util/util.dart';
import 'res/res.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    dotenv.load(fileName: ".env"),
    VersionControlProvider.i.init(),
    StorageProvider.i.init(),
  ]);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AdvertenciasProvider()),
      ChangeNotifierProvider(create: (_) => AgendaProvider()),
      ChangeNotifierProvider(create: (_) => LivrariaProvider()),
      ChangeNotifierProvider(create: (_) => ClubeProvider()),
      ChangeNotifierProvider(create: (_) => CvProvider()),
      ChangeNotifierProvider(create: (_) => EditEspecialidadesProvider()),
      ChangeNotifierProvider(create: (_) => EditMembrosProvider()),
      ChangeNotifierProvider(create: (_) => EspecialidadesProvider()),
      ChangeNotifierProvider(create: (_) => FaltasProvider()),
      ChangeNotifierProvider(create: (_) => FirebaseProvider()),
      ChangeNotifierProvider(create: (_) => InternetProvider()),
      ChangeNotifierProvider(create: (_) => ManuaisProvider()),
      ChangeNotifierProvider(create: (_) => MembrosProvider()),
      ChangeNotifierProvider(create: (_) => PagamentosTaxaProvider()),
      ChangeNotifierProvider(create: (_) => SgcProvider()),
    ],
    child: const Main(),
  ));
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<Main> {

  double _progress = 0;
  Future? _future;

  @override
  void initState() {
    super.initState();

    Tema.i.addListener(_setState);

    _future = AppProvider.initialize(onProgress: _onProgress);
  }

  @override
  Widget build(BuildContext context) {
    Widget material(Widget child) {
      return MaterialApp(
        title: Ressorces.appName,
        debugShowCheckedModeBanner: false,
        scrollBehavior: CustomScrollBehavior(),
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('pt', 'BR')],
        theme: ThemeData(
          primaryColor: Tema.i.primaryColor,
          colorScheme: ColorScheme.fromSeed(seedColor: Tema.i.primaryColor),
          appBarTheme: AppBarTheme(
            color: Tema.i.primaryColor,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: Tema.i.primaryColor,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            contentPadding: EdgeInsets.all(10),
          ),
          useMaterial3: true,
        ),
        home: child,
        builder: (_, w) => ScaffoldMessenger(
          key: Log.key,
          child: w ?? const SplashScreen(),
        ),
      );
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return material(SplashScreen(progress: _progress));
        }

        if (_progress < 1) {
          return material(SafeArea(
            child: Column(
              children: [
                LinearProgressIndicator(value: _progress),

                Expanded(child: _body()),
              ],
            ),
          ));
        }
        return material(_body());
      },
    );
  }

  Widget _body() {
    final fireProv = context.watch<FirebaseProvider>();

    final cvLogado = context.watch<CvProvider>().logado;
    final fireLogado = fireProv.logado;

    if (fireProv.especialLogin) {
      return const RegistrarClubePage();
    }

    if (cvLogado && fireLogado) {
      return const MainPage();
    }

    return const LoginPage();
  }

  void _onProgress(int p, int total) {
    _progress = p / total;
    _setState();
  }

  void _setState() {
    setState(() {});
  }
}