import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/provider.dart';
import '../../util/util.dart';
import '../model/model.dart';
import '../../res/res.dart';

class MembroTile extends StatelessWidget {
  final Membro membro;
  final int? faltas;
  final int? advertencias;
  final Pagamentos? pagamentos;
  final bool enabled;
  final bool dense;
  final bool? importado;
  final bool showSegurado;
  final bool showFichaPendente;
  final Widget? trailing;
  final void Function(Membro)? onTap;
  const MembroTile({
    required super.key,
    this.onTap,
    required this.membro,
    this.faltas,
    this.advertencias,
    this.pagamentos,
    this.enabled = true,
    this.dense = false,
    this.importado,
    this.showSegurado = false,
    this.showFichaPendente = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    String pago = '';
    String aPagar = '';
    double faltaPagar = 0;

    if (pagamentos != null) {
      final mes = DateTime.now().month;
      final total = context.watch<ClubeProvider>().clube.taxaMensal * mes;
      faltaPagar = total;

      // pago = Util.formatarValorDecimal(0, prefix: 'R\$ ');
      // aPagar = Util.formatarValorDecimal(total, prefix: 'R\$ ');

      // if (pagamentos!.isNotEmpty) {
      final totalPago = pagamentos!.totalPago;

      faltaPagar = total - totalPago;
      pago = Formats.formatarValorDecimal(totalPago, prefix: 'R\$ ');
      aPagar = Formats.formatarValorDecimal(faltaPagar, prefix: 'R\$ ');
      // }
    }

    final subtitleStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70);

    List<Widget> subTitle = [
      if (faltas != null)...[
        Text('$faltas Faltas',
          style: subtitleStyle,
        )
      ]
      else if (advertencias != null)...[
        Text('$advertencias Advertências',
          style: subtitleStyle,
        )
      ]
      else if (pagamentos != null)...[
          if (pago.isNotEmpty)
            Text('$pago (Pago)',
              style: subtitleStyle,
            ),
          if (aPagar.isNotEmpty)
            Text('$aPagar (Falta)',
              style: subtitleStyle?.copyWith(color: faltaPagar == 0 ? Colors.green : Colors.redAccent),
            ),

          Text('${pagamentos!.length} Pagamentos',
            style: subtitleStyle,
          ),
        ]
        else if (membro.codFuncao != 0)...[
            Text(membro.cargo,
              style: subtitleStyle,
            ),
          ],

      if (importado != null && !importado!)
        const ImportadoWidget(),

      if (showSegurado)
        SeguradoWidget(segurado: membro.segurado),

      if (showFichaPendente && membro.fichaPendente)
        const FichaPendenteWidget(),
    ];

    return ListTile(
      tileColor: Tema.i.tintDecColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: dense ? null : FotoLayout(
        path: membro.foto,
        aspectRatio: 1/1,
      ),
      title: Text(membro.nomeUsuario,
        maxLines: 2,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
      ),
      subtitle: dense || subTitle.isEmpty ? null : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subTitle,
      ),
      trailing: trailing,
      onTap: (enabled && onTap != null) ? () => onTap?.call(membro) : null,
    );
  }
}

class MembroTileGrid extends StatelessWidget {
  final Membro membro;
  final int? faltas;
  final int? advertencias;
  final int? pagamentos;
  final bool enabled;
  final bool? importado;
  final bool showFichaPendente;
  final Widget? icon;
  final void Function(Membro)? onTap;
  const MembroTileGrid({
    required super.key,
    this.onTap,
    required this.membro,
    this.faltas,
    this.advertencias,
    this.pagamentos,
    this.icon,
    this.enabled = true,
    this.showFichaPendente = false,
    this.importado,
  });

  @override
  Widget build(BuildContext context) {
    var subtitle = membro.cargo;
    if (faltas != null) {
      subtitle = '$faltas Faltas';
    }
    if (advertencias != null) {
      subtitle = '$advertencias Advertencias';
    }
    if (pagamentos != null) {
      subtitle = '$pagamentos Pagamentos';
    }

    return InkWell(
      onTap: enabled ? () => onTap?.call(membro) : null,
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FotoLayout(
                    path: membro.foto,
                    borderRadius: 5,
                  ),

                  if (icon != null)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: icon!,
                    ),

                  if (importado != null && !importado!)
                    const Positioned(
                      top: 5,
                      left: 5,
                      child: ImportadoWidget(),
                    ),

                  if (showFichaPendente && membro.fichaPendente)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FichaPendenteWidget(),
                    ),

                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Tema.i.tintDecColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(membro.nomeUsuario,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(subtitle,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class EventosTile extends StatelessWidget {
  final List<Evento> eventos;
  final bool enabled;
  final void Function(Evento)? onTap;
  const EventosTile({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.eventos,
  });

  @override
  Widget build(BuildContext context) {
    eventos.sort((a, b) => a.dtAgenda.compareTo(b.dtAgenda));

    return Card(
      color: Tema.i.tintDecColor,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(Assets.agendaecTop),
          ),

          Column(
            children: [
              Text(eventos.first.month,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 2,
                    )
                  ]
                ),
              ),

              ListView.builder(
                itemCount: eventos.length,
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 10),
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, i) {
                  final event = eventos[i];

                  return InkWell(
                    onTap: enabled ? () => onTap?.call(event) : null,
                    child: Container(
                      padding:const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: Text('${event.day} - ${event.nomeAgenda}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EventoTile extends StatelessWidget {
  final Evento evento;
  final bool enabled;
  final void Function(Evento)? onTap;
  const EventoTile({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.evento,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(evento.nomeAgenda),
      subtitle: Text(evento.dataText),
      onTap: enabled ? () => onTap?.call(evento) : null,
    );
  }
}


class FaltaTile extends StatelessWidget {
  final Falta falta;
  final bool enabled;
  final void Function(Falta)? onTap;
  const FaltaTile({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.falta,
  });

  @override
  Widget build(BuildContext context) {
    var title = falta.justificativa;
    if (title.isEmpty) title = 'Não justificado';

    return ListTile(
      title: Text(title),
      subtitle: Text(falta.dataText),
      onTap: enabled ? () => onTap?.call(falta) : null,
    );
  }
}

class PagamentoTile extends StatelessWidget {
  final Pagamento pagamento;
  final double valor;
  final bool enabled;
  final void Function(Pagamento)? onTap;
  const PagamentoTile({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.pagamento,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(pagamento.mes),
      subtitle: Text(Formats.formatarValorDecimal(pagamento.valor, prefix: 'R\$ ')),
      trailing: _status(),
      onTap: enabled ? () => onTap?.call(pagamento) : null,
    );
  }

  Text _status() {
    if (pagamento.valor == 0) {
      return const Text(
        'Não Pago',
        style: TextStyle(
          color: Colors.red,
        ),
      );
    }

    if (pagamento.valor < valor) {
      return Text(
        Formats.formatarValorDecimal(valor - pagamento.valor, prefix: 'R\$ ', sufix: ' (Falta)'),
        style: const TextStyle(
          color: Colors.red,
        ),
      );
    }

    return const Text(
      'Pago',
      style: TextStyle(
        color: Colors.green,
      ),
    );
  }
}

class AdvertenciaTile extends StatelessWidget {
  final Advertencia advertencia;
  final bool enabled;
  final void Function(Advertencia)? onTap;
  const AdvertenciaTile({
    super.key,
    this.onTap,
    this.enabled = true,
    required this.advertencia,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(advertencia.descricao),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(advertencia.punicao),
          Text(advertencia.dataText,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
      onTap: enabled ? () => onTap?.call(advertencia) : null,
    );
  }
}


class QuestaoTile extends StatelessWidget {
  final Questao questao;
  final void Function(Questao)? onEditTap;
  final void Function(String)? onOpenPdfTap;
  const QuestaoTile({
    super.key,
    required this.questao,
    this.onEditTap,
    this.onOpenPdfTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        iconColor: questao.respondido ? Colors.green : Colors.red,
        collapsedIconColor: questao.respondido ? Colors.green : Colors.red,
        childrenPadding: const EdgeInsets.symmetric(horizontal: 10),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        collapsedBackgroundColor: tileColor(),
        backgroundColor: tileColor(),
        title: Text(questao.name),
        subtitle: subtitle(),
        children: [
          for(var item in questao.subQuestoes)
            QuestaoTile(
              questao: item,
              onEditTap: onEditTap,
              onOpenPdfTap: onOpenPdfTap,
            ),

          if (questao.respondido)...[
            Text(questao.resposta,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),

            Row(
              children: [
                Text(questao.data,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),  // data

                const Spacer(),

                if (questao.sendFile)
                  TextButton.icon(
                    onPressed: () => onOpenPdfTap?.call(questao.fileUrl),
                    label: const Text('Ver PDF'),
                    icon: const Icon(Icons.picture_as_pdf,
                    color: Colors.green,
                  ),
                  ),

                if (questao.url.isNotEmpty)
                  TextButton(
                    onPressed: () => onEditTap?.call(questao),
                    child: const Text('Editar'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget? subtitle() {
    if (questao.respondido || questao.url.isEmpty) return null;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => onEditTap?.call(questao),
            child: const Text('Responder'),
          ),
        ),

        if (questao.sendFile)
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Icon(Icons.picture_as_pdf),
          ),
      ],
    );
  }

  Color? tileColor() {
    if (questao.contensEspecialChar && kDebugMode) return Colors.red;

    return null;
  }
}


class LivroGridTile extends StatelessWidget {
  final Livro livro;
  final bool readOnly;
  final void Function(Livro)? onTap;
  final void Function(Livro)? onEditTap;
  const LivroGridTile({
    required super.key,
    required this.livro,
    this.onTap,
    this.onEditTap,
    this.readOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap == null ? null : () => onTap?.call(livro),
      child: Card(
        margin: EdgeInsets.zero,
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: FotoLayout(
                    path: livro.urlCapa,
                    borderRadius: 5,
                    saveTo: livro.imageFile,
                    headers: FirebaseProvider.i.storage.headers,
                  ),
                ),

                Container(
                  height: 54,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Tema.i.tintDecColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(livro.nome,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),

                      Flexible(
                        child: Text(livro.descricao,
                          maxLines: livro.autor.isEmpty ? 2 : 1,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      if (livro.autor.isNotEmpty)
                        Text(livro.autor,
                          maxLines: 1,
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (livro.livroDoAno)
              Positioned(
                top: 5,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 1
                      ),
                    ],
                  ),
                  child: const Text('Livro do ano'),
                ),
              ),

            if (!readOnly)
              Container(
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: IconButton(
                  tooltip: 'Editar',
                  onPressed: () => onEditTap?.call(livro),
                  icon: const Icon(Icons.edit),
                  iconSize: 20,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EspecialidadeTile extends StatelessWidget {
  final Especialidade especialidade;
  final bool enabled;
  final bool dense;
  final void Function(Especialidade)? onTap;
  final Widget? trailing;
  const EspecialidadeTile({
    required super.key,
    required this.especialidade,
    this.onTap,
    this.enabled = true,
    this.dense = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        // tileColor: especialidade.text.isEmpty ? null : Colors.green,
        onTap: (enabled && onTap != null) ? () => onTap?.call(especialidade) : null,
        leading: dense ? null : FotoLayout(
          path: especialidade.image,
          borderRadius: 50,
          aspectRatio: 1/1,
          fit: BoxFit.fill,
          saveTo: especialidade.imageFile,
        ),
        title: Text(especialidade.nome),
        subtitle: dense ? null : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(especialidade.area),
            Text(especialidade.departamento),
          ],
        ),
        trailing: trailing,
      ),
    );
  }
}

class ClasseItemTile extends StatelessWidget {
  final ClasseItem classe;
  final bool enabled;
  final void Function(ClasseItem)? onTap;
  final Widget? trailing;
  const ClasseItemTile({
    required super.key,
    required this.classe,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: (enabled && onTap != null) ? () => onTap?.call(classe) : null,
        title: Text(classe.nome),
        trailing: trailing,
      ),
    );
  }
}

class EspecialidadeAreaTile extends StatelessWidget {
  final EspecialidadeArea area;
  final int espCout;
  final bool enabled;
  final void Function(EspecialidadeArea)? onTap;
  final Widget? trailing;
  const EspecialidadeAreaTile({
    super.key,
    required this.area,
    this.espCout = 0,
    this.onTap,
    this.enabled = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: area.lightText ? Colors.white : Colors.black,
    );
    final styleSub = TextStyle(
      color: area.lightText ? Colors.white60 : Colors.black87,
    );

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: area.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: area.borderColor ?? Colors.white,
          width: 5,
        ),
      ),
      child: ListTile(
        onTap: enabled ? () => onTap?.call(area) : null,
        leading: Text(area.id, style: style),
        // leading: FotoLayout(
        //   path: area.image,
        //   borderRadius: 50,
        //   aspectRatio: 1/1,
        //   fit: BoxFit.fill,
        // ),
        title: Text(area.nome, style: style),
        subtitle: Text('Especialidades: $espCout', style: styleSub),
        trailing: trailing,
      ),
    );
  }
}

class UnidateTile extends StatelessWidget {
  final Unidade unidade;
  final void Function(Unidade)? onTap;
  final void Function(Unidade)? onMembrosTap;
  final void Function(Unidade)? onDeleteTap;
  const UnidateTile({
    super.key,
    required this.unidade,
    this.onTap,
    this.onDeleteTap,
    this.onMembrosTap,
  });

  @override
  Widget build(BuildContext context) {
    const subStyle = TextStyle(fontSize: 10);

    return ListTile(
      onTap: () => onTap?.call(unidade),
      title: Text(unidade.nomeUnidade),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (unidade.nomeConselheiro.isEmpty && unidade.membrosCount > 0)
            Text('Sem conselheiro', style: subStyle.copyWith(color: Colors.red))
          else
            Text(unidade.nomeConselheiro, style: subStyle),

          Text('Membros: ${unidade.membrosCount}', style: subStyle),
        ],
      ),
      trailing: unidade.canDelete ? IconButton(
        tooltip: 'Remover',
        onPressed: () => onDeleteTap?.call(unidade),
        icon: const Icon(Icons.delete_forever),
      ) :
      ElevatedButton(
        onPressed: () => onMembrosTap?.call(unidade),
        child: const Text('Membros'),
      ),
    );
  }
}


class SeguroRemessaTile extends StatelessWidget {
  final SeguroRemessa seguro;
  final void Function(SeguroRemessa)? onTap;
  final void Function(SeguroRemessa)? onTransferTap;
  final void Function(SeguroRemessa)? onDeleteTap;
  final bool enabled;
  const SeguroRemessaTile({
    required super.key,
    required this.seguro,
    this.onTap,
    this.onTransferTap,
    this.onDeleteTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget? trailing() {
      if (seguro.canDelete) {
        return CircleAvatar(
          child: IconButton(
            tooltip: 'Excluir seguro',
            onPressed: () => onDeleteTap!.call(seguro),
            icon: const Icon(Icons.clear,
              color: Colors.red,
            ),
          ),
        );
      }

      if (onTransferTap != null && seguro.codVida != 0) {
        return CircleAvatar(
          backgroundColor: Colors.greenAccent,
          child: IconButton(
            tooltip: 'Transferir Seguro',
            onPressed: () => onTransferTap!.call(seguro),
            icon: const Icon(Icons.repeat),
          ),
        );
      }

      return null;
    }
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(seguro.nomeUsuario),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(seguro.funcao),
            if (!seguro.ativo)
              const Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('Inativo',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        leading: FotoLayout(
          path: seguro.foto,
          aspectRatio: 1/1,
        ),
        trailing: trailing(),
      ),
    );
  }
}



