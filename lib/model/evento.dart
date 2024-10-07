import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../util/util.dart';
import 'model.dart';

class Evento extends ItemModel {

  @override
  String get id => '_$codAgenda';

  String nomeAgenda = '';
  String descAgenda = '';
  String dtAgenda = '';
  String dtAgendaFim = '';

  String dtLembrete = '';
  String emailLembrete = '';
  String txtLembrete = '';

  int codAgenda = 0;
  int codTipoAgenda = 0;
  bool opcao = false; // receber email de notificação

  Evento({
    this.nomeAgenda = '',
    this.descAgenda = '',
    this.dtAgenda = '',
    this.dtAgendaFim = '',

    this.dtLembrete = '',
    this.emailLembrete = '',
    this.txtLembrete = '',

    this.codAgenda = 0,
    this.codTipoAgenda = 0,

    this.opcao = false,
  });

  Evento.fromJson(Map? map) :
        nomeAgenda = map?['nome_agenda'] ?? '',
        descAgenda = map?['desc_agenda'] ?? '',
        dtAgenda = map?['dt_agenda'] ?? '',
        dtAgendaFim = map?['dt_agenda_fim'] ?? '',

        dtLembrete = map?['dt_lembrete'] ?? '',
        emailLembrete = map?['email_lembrete'] ?? '',
        txtLembrete = map?['txt_lembrete'] ?? '',

        codAgenda = map?['cod_agenda'] ?? 0,
        codTipoAgenda = map?['cod_tipo_agenda'] ?? 0,

        opcao = map?['opcao'] ?? 0;

  static Map<String, Evento> fromJsonList(Map? map) {
    Map<String, Evento> items = {};

    map?.forEach((key, value) {
      items[key] = Evento.fromJson(value);
    });

    return items;
  }

  @override
  Map<String, dynamic> toJson() => {
    'nome_agenda': nomeAgenda,
    'desc_agenda': descAgenda,
    'dt_agenda': _convertDate(dtAgenda),
    'dt_agenda_fim': dtAgendaFim,

    'dt_lembrete': dtLembrete,
    'email_lembrete': emailLembrete,
    'txt_lembrete': txtLembrete,

    'cod_agenda': codAgenda,
    'cod_tipo_agenda': codTipoAgenda,
    'opcao': opcao,
  };


  String get dataText {
    var sp = Formats.convertTime(from?.millisecondsSinceEpoch ?? 0).split('-');

    int mes = int.parse(sp[0]);
    int dia = int.parse(sp[1]);

    var diaS = dia.toString();
    if (diaS.length == 1) diaS = '0$dia';

    return '$diaS de ${Formats.intToMes(mes)}';
  }

  String get day {
    var dia = from?.day.toString() ?? '';
    if (dia.length == 1) dia = '0$dia';

    return dia;
  }

  String get month {
    return Formats.intToMes(from?.month ?? 0);
  }

  bool get variosDias {
    if (dtAgendaFim.isEmpty && codAgenda != 0) return true;
    return from != to;
  }

  DateTime? get from => Formats.stringToDateTime(dtAgenda);
  DateTime? get to => Formats.stringToDateTime(dtAgendaFim) ?? from;

  List<DateTime> get dias {
    final de = from!;
    final ate = to!;
    List<DateTime> items = [];

    var dia1 = de.day;
    var dia2 = ate.day;

    if (de.month == ate.month) {
      for(int i = dia1; i <= dia2; i++) {
        items.add(DateTime(de.year, de.month, i));
      }
    } else {
      List<int> meses31 = [1, 3, 5, 7, 8, 10, 12];

      int lastDay = 30;
      if (de.month == 2) { // verificar se o ano é bissexto
        if (Util.isAnoBissexto(de.year)) {
          lastDay = 29;
        } else {
          lastDay = 28;
        }
      } else if (meses31.contains(de.month)) {
        lastDay = 31;
      }

      for(int i = dia1; i <= lastDay; i++) {
        items.add(DateTime(de.year, de.month, i));
      }
      for(int i = 1; i <= ate.day; i++) {
        items.add(DateTime(ate.year, ate.month, i));
      }
    }

    return items;
  }


  Evento copy() => Evento.fromJson(toJson());

  @override
  String toString() => toJson().toString();


  String _convertDate(String value) {
    final date = Formats.stringToDateTime(value);
    return Formats.dataHoraUs(date);
  }
}

class EventoDataSource extends CalendarDataSource<Evento> {
  EventoDataSource(this.source);

  List<Appointment> source;

  @override
  List<Appointment> get appointments => source;

}
