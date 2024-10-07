import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends StateListPage<AgendaPage> {

  EventoDataSource _dataSource = EventoDataSource([]);
  final _calendarController = CalendarController();

  bool _showAllEvents = pref.getBool(PrefKey.eventosShowAll);

  late DateTime _dateTime;

  bool _inProgress = false;

  @override
  String get title => 'Agenda';

  @override
  String? get custonTitle => title;

  @override
  void dispose() {
    super.dispose();
    _calendarController.dispose();
  }

  @override
  void initState() {
    _dateTime = DateTime.now();
    _calendarController.selectedDate = _dateTime;
    _calendarController.view = _showAllEvents ? CalendarView.schedule : CalendarView.month;
    _calendarController.addPropertyChangedListener((details) {
      _loadAgenda();
    });
    super.initState();
  }

  @override
  Widget upBuilder() {
    return Column(
      children: [
        if (_inProgress || !loaded)
          const LinearProgressIndicator(),

        SwitchListTile(
          title: const Text('Ver todos os eventos'),
          value: _showAllEvents,
          onChanged: (value) {
            _showAllEvents = value;
            pref.setBool(PrefKey.eventosShowAll, value);

            if (value) {
              _calendarController.view = CalendarView.schedule;
            } else {
              _calendarController.view = CalendarView.month;
            }
            _setState();
          },
        ),
      ],
    );
  }

  @override
  Widget builder() {
    if (_showAllEvents) {
      return SfCalendar(
        controller: _calendarController,
        showDatePickerButton: true,
        dataSource: EventoDataSource(_getAppointments(AgendaProvider.i.list)),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          showTrailingAndLeadingDates: false,
        ),
        scheduleViewMonthHeaderBuilder: (context, details) {
          final mes = details.date.month;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.brown,
              image: DecorationImage(
                image: AssetImage('assets/images/mes_$mes.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Text(Formats.intToMes(mes),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  BoxShadow(
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          SizedBox(
            height: 300,
            child: SfCalendar(
              controller: _calendarController,
              showDatePickerButton: true,
              showNavigationArrow: true,
              dataSource: _dataSource,
              monthViewSettings: const MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showTrailingAndLeadingDates: false,
              ),
            ),
          ),  // calendário

          ListView.separated(
            shrinkWrap: true,
            itemCount: _dataSource.appointments.length,
            padding: const EdgeInsets.all(10),
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, i) => const SizedBox(height: 5),
            itemBuilder: (context, i) {
              final item = _dataSource.appointments[i];
              final evento = item.recurrenceId as Evento;

              String dia(DateTime data) {
                var dia = '${data.day}';
                if (dia.length == 1) dia = '0$dia';
                return dia;
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < evento.dias.length; i++)...[
                    Builder(
                      builder: (context) {
                        String title = evento.nomeAgenda;
                        String subtitle = '';
                        if (evento.variosDias) {
                          subtitle = '(Dia ${i +1} de ${evento.dias.length})';
                        }

                        final data = evento.dias[i];
                        const style = TextStyle(color: Colors.white);

                        return Row(
                          children: [
                            SizedBox(
                              width: 30,
                              child: Text(dia(data),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(left: 10),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: item.color,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(title, style: style),
                                    Text(Arrays.tipoEvento[evento.codTipoAgenda] ?? '',
                                      style: style,
                                    ),

                                    if (subtitle.isNotEmpty)
                                      Text(subtitle,
                                        style: style.copyWith(fontSize: 12),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 2),
                  ]
                ],
              );
            },
          ), // schedule
        ],
      ),
    );
  }

  @override
  Future<void> fufureVoid() async {
    await AgendaProvider.i.loadOnline(_dateTime.year);
    _loadAgenda();
  }

  @override
  Future<bool> onRefresh() async {
    if (!await super.onRefresh()) return false;

    final date = _calendarController.displayDate!;
    await AgendaProvider.i.refresh(date.year);
    _loadAgenda();

    return true;
  }

  void _loadAgenda() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final date = _calendarController.displayDate;
    if (date == null) return;

    if (date.year != _dateTime.year) {
      _setInProgress(true);
      await onRefresh();
      _setInProgress(false);
    }
    _dateTime = date;

    final eventos = AgendaProvider.i.getByMother(_dateTime.month);

    _dataSource = EventoDataSource(_getAppointments(eventos));
    _setState();
  }

  List<Appointment> _getAppointments(List<Evento> eventos) {
    final List<Appointment> appointments = <Appointment>[];

    for (var ev in eventos) {
      final from = ev.from;
      final to = ev.to;
      if (from == null || to == null) continue;

      final recurrence = RecurrenceProperties(
        startDate: from,
        endDate: to,
        recurrenceType: RecurrenceType.daily,
        recurrenceRange: RecurrenceRange.count,
        recurrenceCount: 1,
        month: from.month,
        dayOfMonth: from.day,
        dayOfWeek: from.weekday,
      );

      final appointment = Appointment(
        startTime: from,
        endTime: to,
        color: Ressorces.colorFromEventType(ev.codTipoAgenda),
        subject: ev.nomeAgenda,
        isAllDay: true,
        recurrenceRule: SfCalendar.generateRRule(recurrence, from, to),
        recurrenceId: ev,
        id: recurrence,
      );

      appointments.add(appointment);
    }

    for (var membro in MembrosProvider.i.list) {
      var dataNiver = membro.dataNascimento;
      var dataController = _calendarController.displayDate;

      if (dataNiver == null || dataController == null) continue;
      if (!_showAllEvents && dataNiver.month != dataController.month) continue;
      dataNiver = DateTime(dataController.year, dataNiver.month, dataNiver.day);

      final ev = Evento(
        nomeAgenda: membro.nomeUsuario,
        dtAgenda: membro.dtNascimento,
        codTipoAgenda: 2222,
      );

      final recurrence = RecurrenceProperties(
        startDate: dataNiver,
        endDate: dataNiver,
        recurrenceType: RecurrenceType.yearly,
        recurrenceRange: RecurrenceRange.count,
        recurrenceCount: 100,
        month: dataNiver.month,
        dayOfMonth: dataNiver.day,
        dayOfWeek: dataNiver.weekday,
      );

      final appointment = Appointment(
        startTime: dataNiver,
        endTime: dataNiver,
        color: Ressorces.colorFromEventType(ev.codTipoAgenda),
        subject: ev.nomeAgenda,
        isAllDay: true,
        recurrenceRule: SfCalendar.generateRRule(recurrence, dataNiver, dataNiver),
        recurrenceId: ev,
        id: recurrence,
      );

      appointments.add(appointment);
    }

    appointments.sort((a, b) => a.startTime.day.compareTo(b.startTime.day));

    return appointments;
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

// @Deprecated('Use AgendaPage')
// class AgendaOldPage extends PageBaseList {
//   const AgendaOldPage({super.key});
//
//   @override
//   State<StatefulWidget> createState() => _StateOld();
// }
// // ignore: deprecated_member_use_from_same_package
// class _StateOld extends PageBaseListState<AgendaOldPage, List<Evento>, AgendaProvider> {
//
//   @override
//   String get title => 'Agenda';
//
//   @override
//   String get custonTitle => title;
//
//   @override
//   String? get addButtonCustonText => 'Novo Evento';
//
//   @override
//   bool get showActionButton => false;
//
//   @override
//   bool get showDate => true;
//
//   @override
//   List<List<Evento>> get items {
//     return  provider.groupByMonth().values.toList();
//   }
//
//   @override
//   Widget itemBuilder(List<Evento> values) {
//     return EventosTile(
//       eventos: values,
//       enabled: !FirebaseProvider.i.readOnly,
//       onTap: onEventoTap,
//     );
//   }
//
//   void onEventoTap(Evento evento) {
//     Navigate.push(context, EventoPage(
//       model1: evento.copy(),
//       readOnly: FirebaseProvider.i.readOnly,
//     ));
//   }
//
//   @override
//   void onAddTap() {
//     Navigate.push(context, EventoPage(
//       model1: Evento(),
//       readOnly: FirebaseProvider.i.readOnly,
//     ));
//   }
//
// }
