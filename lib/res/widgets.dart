import 'dart:io';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'res.dart';

class AnoCorrenteDropDown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final void Function(T?) onChanged;
  const AnoCorrenteDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Tema.i.tintDecColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonFormField(
        value: value,
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text('$e'),
        )).toList(),
        style: const TextStyle(
          color: Colors.white,
        ),
        dropdownColor: Tema.i.tintDecColor,
        decoration: const InputDecoration(
          labelText: 'Ano corrente',
          labelStyle: TextStyle(
            color: Colors.white,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class AvisoDataNaoPodeSerAltera extends StatelessWidget {
  const AvisoDataNaoPodeSerAltera({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Depois de salvo a data não pode ser alterada',
      style: TextStyle(
        color: Colors.red,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  final String? imageUrl;
  final double? progress;
  const SplashScreen({
    super.key,
    this.imageUrl,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var imageSize = (size.height < size.width) ? size.height : size.width;
    if (imageSize > 500) {
      imageSize = imageSize/2;
    }

    const padding = 20.0;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: Tema.i.primaryColor,
        child: Center(
          child: Container(
            width: imageSize,
            height: imageSize,
            padding: const EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: FotoLayout(
                    path: imageUrl ?? '',
                    saveTo: Ressorces.clubeLogo,
                    borderRadius: 0,
                    backgroundColor: Colors.transparent,
                    erroIcon: Image.asset(Assets.clubeLogo),
                  ),
                ),

                const SizedBox(height: 30),

                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FotoLayout extends StatelessWidget {
  final String path;
  final Widget? erroIcon;
  final double? aspectRatio;
  final double borderRadius;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final BoxFit fit;
  final File? saveTo;
  final Map<String, String>? headers;
  const FotoLayout({
    super.key,
    required this.path,
    this.aspectRatio,
    this.erroIcon,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderRadius = 100,
    this.fit = BoxFit.cover,
    this.headers,
    this.saveTo,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.white,
      child: _fotoTile(),
    );

    Widget rect(Widget child) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      );
    }

    if (aspectRatio == null) {
      return rect(child);
    }

    return rect(AspectRatio(
      aspectRatio: aspectRatio!,
      child: child,
    ));
  }

  Widget _fotoTile() {
    Widget error(c, o, e) {
      return erroIcon ?? const Center(child: Icon(Icons.person));
    }

    if (saveTo != null) {
      return Image(
        fit: fit,
        image: NetworkToFileImage(
          url: path,
          file: saveTo,
          headers: headers,
        ),
        errorBuilder: error,
        loadingBuilder: (c, w, p) {
          if (p == null) return w;

          return Center(
            child: CircularProgressIndicator(
              value: p.cumulativeBytesLoaded / (p.expectedTotalBytes ?? 1),
            ),
          );
        },
      );
    }

    return FastCachedImage(
      url: path,
      fit: fit,
      headers: headers,
      showErrorLog: false,
      errorBuilder: error,
      fadeInDuration: const Duration(milliseconds: 100),
      loadingBuilder: (c, e) {
        return Center(
          child: CircularProgressIndicator(
            value: e.progressPercentage.value,
          ),
        );
      },
    );
  }
}

class SgcAppBar extends AppBar {
  SgcAppBar({
    super.key,
    super.leading,
    super.automaticallyImplyLeading = true,
    super.title,
    super.actions,
    super.flexibleSpace,
    super.bottom,
    super.elevation,
    super.scrolledUnderElevation,
    super.notificationPredicate = defaultScrollNotificationPredicate,
    super.shadowColor,
    super.surfaceTintColor,
    super.shape,
    super.backgroundColor = Colors.black,
    super.foregroundColor = Colors.white,
    super.iconTheme,
    super.actionsIconTheme,
    super.primary = true,
    super.centerTitle,
    super.excludeHeaderSemantics = false,
    super.titleSpacing,
    super.toolbarOpacity = 1.0,
    super.bottomOpacity = 1.0,
    super.toolbarHeight,
    super.leadingWidth,
    super.toolbarTextStyle,
    super.titleTextStyle,
    super.forceMaterialTransparency = false,
    super.clipBehavior,
    super.systemOverlayStyle = const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ),
  });

}

class FichaPendenteWidget extends StatelessWidget {
  const FichaPendenteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: const Text('Ficha Médica Pendente'),
    );
  }
}

class ImportadoWidget extends StatelessWidget {
  const ImportadoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: const Text('Não importado',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class SeguradoWidget extends StatelessWidget {
  final bool segurado;
  const SeguradoWidget({super.key, required this.segurado});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: segurado ? Colors.green : Colors.redAccent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text('${segurado ? '' : 'Não '}Segurado',
        style: const TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }
}

class SgcMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final void Function()? onTap;
  const SgcMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: Icon(icon,
                size: 55,
              ),
            ),

            Positioned(
              top: 10,
              left: 20,
              child: Text(title,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
            ),

            if (subtitle != null)
              Positioned(
                bottom: 10,
                left: 20,
                child: Text(subtitle!),
              ),
          ],
        ),
      ),
    );
  }
}

Widget errorBuiler(c, o, e) {
  return const Icon(Icons.person,
    size: 55,
  );
}
Widget errorBuilerP(c, o, e) {
  return const Icon(Icons.person,
    // size: 55,
  );
}
Widget loadingBuiler(BuildContext c, Widget w, ImageChunkEvent? e) {
  if (e == null) {
    return w;
  }

  return Center(
    child: CircularProgressIndicator(
      value: e.cumulativeBytesLoaded / (e.expectedTotalBytes ?? 1),
    ),
  );
}