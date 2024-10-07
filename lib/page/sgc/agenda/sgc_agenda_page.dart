import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

class SgcAgendaPage extends StatefulWidget {
  const SgcAgendaPage({super.key});

  @override
  State<StatefulWidget> createState() => _State();
}
class _State extends State<SgcAgendaPage> {

  EventoDataSource _dataSource = EventoDataSource([]);
  final _calendarController = CalendarController();
  ViewChangedDetails? details;

  final List<Evento> _eventos = [];

  bool _inProgress = false;

  @override
  void initState() {
    super.initState();
    _calendarController.selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SgcAppBar(
        title: const Text('Agenda'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 70),
        child: Column(
          children: [
            if (_inProgress)
              const LinearProgressIndicator(),

            SizedBox(
              height: 300,
              child: SfCalendar(
                controller: _calendarController,
                view: CalendarView.month,
                showDatePickerButton: true,
                showNavigationArrow: true,
                onViewChanged: _loadAgenda,
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

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => _onEventoTap(evento),
                              child: Row(
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
                              ),
                            ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onEventoTap,
        label: const Text('Novo Evento'),
      ),
    );
  }


  void _loadAgenda(ViewChangedDetails details) async {
    this.details = details;

    final mid = details.visibleDates.length ~/ 2;
    final date = details.visibleDates[mid];
    await Future.delayed(const Duration(milliseconds: 100));
    _setInProgress(true);

    _eventos.clear();
    _eventos.addAll(await SgcProvider.i.getEventos(date.month, date.year));

    _dataSource = EventoDataSource(_getAppointments());
    _dataSource.notifyListeners(CalendarDataSourceAction.reset, _getAppointments());
    _setInProgress(false);
  }

  void _onEventoTap([Evento? value]) async {
    final res = await Navigate.push(context, SgcEventoPage(evento: value?.copy() ?? Evento()));
    if (res == true) {
      _loadAgenda(details!);
    }
  }

  List<Appointment> _getAppointments() {
    final List<Appointment> appointments = <Appointment>[];

    for (var ev in _eventos) {
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
