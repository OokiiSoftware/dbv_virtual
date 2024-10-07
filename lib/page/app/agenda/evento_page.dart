// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../provider/provider.dart';
// import '../../../model/model.dart';
// import '../../../page/page.dart';
// import '../../../util/util.dart';

// class EventoPage extends PageBaseItem {
//   const EventoPage({
//     super.key,
//     required super.model1,
//     super.readOnly,
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends PageBaseItemState<EventoPage, Evento, Evento, AgendaProvider> {
//
//   @override
//   String get title => 'Evento';
//
//   @override
//   bool get showSaveButton => false;
//
//   @override
//   bool get showDeleteButton => false;
//
//   @override
//   List<Widget> get formContent {
//     final hoje = DateTime.now();
//     var initialDate = hoje;
//     if (!isNovo) {
//       initialDate = Formats.stringToDateTime(model1.dtAgenda) ?? hoje;
//     }
//
//     return [
//       TextFormField(
//         initialValue: model1.nomeAgenda,
//         readOnly: readOnly,
//         keyboardType: TextInputType.name,
//         decoration: const InputDecoration(
//           labelText: 'Titulo',
//         ),
//         validator: Validators.obrigatorio,
//         onSaved: (value) => model1.nomeAgenda = value!,
//       ),
//
//       AbsorbPointer(
//         absorbing: !isNovo || readOnly,
//         child: CalendarDatePicker(
//           initialDate: initialDate,
//           firstDate: DateTime(hoje.year),
//           lastDate: DateTime(hoje.year + 2),
//           onDateChanged: (DateTime value) {
//             model1.dtAgenda = Formats.data(value);
//           },
//         ),
//       ),
//     ];
//   }
//
//   @override
//   Future<bool> onSave() async {
//     if (model1.dtAgenda.isEmpty) {
//       model1.dtAgenda = Formats.data(DateTime.now());
//     }
//
//     return true;
//   }
//
// }
