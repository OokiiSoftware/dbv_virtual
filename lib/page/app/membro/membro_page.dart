import 'dart:io';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:provider/provider.dart';
import '../../../provider/provider.dart';
import '../../../model/model.dart';
import '../../../util/util.dart';
import '../../../res/res.dart';
import '../../page.dart';

// class MembroPage extends PageBaseItem {
//   const MembroPage({
//     super.key,
//     required super.model1,
//     super.readOnly
//   });
//
//   @override
//   State<StatefulWidget> createState() => _State();
// }
// class _State extends PageBaseItemState<MembroPage, Membro, Membro, MembrosProvider> {
//
//   late final MaskedTextController _dateController = MaskedTextController(
//     mask: Masks.date,
//     text: model1.dtNascimento,
//   );
//
//   final _anoNasc = TextEditingController();
//
//   XFile? _image;
//
//   @override
//   String get title => 'Membro';
//
//   @override
//   bool get showSaveButton => false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _onNascChanged(model1.dtNascimento);
//   }
//
//   @override
//   List<Widget> get formContent {
//     bool meuPerfil = context.watch<FirebaseProvider>().user.id == model1.id;
//
//     const space = SizedBox(height: 20);
//     const contentPadding = EdgeInsets.all(10);
//
//     return [
//       ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: _fotoTile(),
//       ),  // foto
//
//       Card(
//         margin: const EdgeInsets.only(top: 10),
//         child: Column(
//           children: [
//             TextFormField(
//               initialValue: model1.nomeUsuario,
//               readOnly: true,
//               keyboardType: TextInputType.name,
//               inputFormatters: TextType.name.upperCase.inputFormatters,
//               decoration: const InputDecoration(
//                 labelText: 'Nome',
//                 contentPadding: contentPadding,
//               ),
//               validator: Validators.obrigatorio,
//               onSaved: (value) => model1.nomeUsuario = value!,
//             ),  // nome
//
//             AbsorbPointer(
//               absorbing: true,
//               child: DropdownButtonFormField(
//                 value: model1.codFuncao,
//                 items: Arrays.funcoes.keys.map((e) => DropdownMenuItem(
//                   value: e,
//                   child: Text(Arrays.funcoes[e]!),
//                 )).toList(),
//                 decoration: const InputDecoration(
//                   labelText: 'Cargo',
//                   contentPadding: contentPadding,
//                 ),
//                 onChanged: _onCargoChanged,
//               ),
//             ),  // cargo
//
//             TextFormField(
//               controller: _dateController,
//               keyboardType: TextInputType.datetime,
//               readOnly: true,
//               decoration: const InputDecoration(
//                 labelText: 'Data de Nascimento',
//                 contentPadding: contentPadding,
//               ),
//               onSaved: (value) => model1.dtNascimento = value!,
//               validator: Validators.dataObrigatorio,
//               onChanged: _onNascChanged,
//             ),  // nascimento
//           ],
//         ),
//       ),  // dados
//
//       const SizedBox(height: 10),
//
//       Card(
//         margin: EdgeInsets.zero,
//         child: Column(
//           children: [
//             const Text('Endereço'),
//
//             TextFormField(
//               initialValue: model1.endereco,
//               keyboardType: TextInputType.name,
//               readOnly: true,
//               inputFormatters: TextType.name.upperCase.inputFormatters,
//               decoration: const InputDecoration(
//                 labelText: 'Endereço',
//                 contentPadding: contentPadding,
//               ),
//             ),
//
//             /*Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(
//                   width: 80,
//                   child: TextFormField(
//                     initialValue: model1.endereco,
//                     keyboardType: TextInputType.name,
//                     readOnly: true,
//                     maxLength: 2,
//                     inputFormatters: TextType.name.upperCase.inputFormatters,
//                     decoration: const InputDecoration(
//                       labelText: 'País',
//                       contentPadding: contentPadding,
//                     ),
//                     // onSaved: (value) => model1.endereco.pais = value!,
//                   ),
//                 ),  // pais
//
//                 *//*Expanded(
//                   child: TextFormField(
//                     initialValue: model1.endereco.estado,
//                     readOnly: true,
//                     keyboardType: TextInputType.name,
//                     inputFormatters: TextType.name.upperCase.inputFormatters,
//                     decoration: const InputDecoration(
//                       labelText: 'Estado',
//                       contentPadding: contentPadding,
//                     ),
//                     onSaved: (value) => model1.endereco.estado = value!,
//                   ),
//                 ),*//*  // estado
//               ],
//             ),*/
//
//             /*TextFormField(
//               initialValue: model1.endereco.cidade,
//               readOnly: true,
//               keyboardType: TextInputType.name,
//               inputFormatters: TextType.name.upperCase.inputFormatters,
//               decoration: const InputDecoration(
//                 labelText: 'Cidade',
//                 contentPadding: contentPadding,
//               ),
//               onSaved: (value) => model1.endereco.cidade = value!,
//             ),  //
//
//             TextFormField(
//               initialValue: model1.endereco.bairro,
//               readOnly: true,
//               keyboardType: TextInputType.name,
//               inputFormatters: TextType.name.upperCase.inputFormatters,
//               decoration: const InputDecoration(
//                 labelText: 'Bairro',
//                 contentPadding: contentPadding,
//               ),
//               onSaved: (value) => model1.endereco.bairro = value!,
//             ),  // bairro
//
//             TextFormField(
//               initialValue: model1.endereco.rua,
//               readOnly: true,
//               keyboardType: TextInputType.name,
//               inputFormatters: TextType.name.upperCase.inputFormatters,
//               decoration: const InputDecoration(
//                 labelText: 'Rua',
//                 contentPadding: contentPadding,
//               ),
//               onSaved: (value) => model1.endereco.rua = value!,
//             ),  // rua
//
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: model1.endereco.num,
//                     readOnly: true,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: TextType.numero.inputFormatters,
//                     decoration: const InputDecoration(
//                       labelText: 'Número',
//                       contentPadding: contentPadding,
//                     ),
//                     onSaved: (value) => model1.endereco.num = value!,
//                   ),
//                 ),  // num
//
//                 Expanded(
//                   child: TextFormField(
//                     initialValue: model1.endereco.cep,
//                     readOnly: true,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: TextType.cep.inputFormatters,
//                     decoration: const InputDecoration(
//                       labelText: 'Cep',
//                       contentPadding: contentPadding,
//                     ),
//                     onSaved: (value) => model1.endereco.cep = value!,
//                   ),
//                 ),  // cep
//               ],
//             ),*/
//           ],
//         ),
//       ),  // Endereço
//
//       if (!readOnly || meuPerfil)...[
//         const SizedBox(height: 10),
//         Card(
//           margin: EdgeInsets.zero,
//           color: Colors.white,
//           child: Column(
//             children: [
//               const Text('Dados de login'),
//
//               TextFormField(
//                 initialValue: model1.emailUsuario,
//                 keyboardType: TextInputType.emailAddress,
//                 inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
//                 readOnly: true,
//                 decoration: const InputDecoration(
//                   labelText: 'Email',
//                   contentPadding: contentPadding,
//                 ),
//                 // validator: Validators.obrigatorio,
//                 onSaved: (value) => model1.emailUsuario = value!,
//               ),  // email
//
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       initialValue: model1.codUsuario.toString(),
//                       readOnly: true,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: TextType.numero.inputFormatters,
//                       decoration: const InputDecoration(
//                         labelText: 'Código',
//                         contentPadding: contentPadding,
//                       ),
//                       // validator: Validators.obrigatorio,
//                       // onSaved: (value) => model1.codigo = value!,
//                     ),
//                   ),  // Código
//
//                   SizedBox(
//                     width: 140,
//                     child: TextFormField(
//                       controller: _anoNasc,
//                       readOnly: true,
//                       keyboardType: TextInputType.number,
//                       inputFormatters: TextType.numero.inputFormatters,
//                       decoration: const InputDecoration(
//                         labelText: 'Ano Nascimento',
//                         contentPadding: contentPadding,
//                       ),
//                     ),
//                   ),  // ano
//                 ],
//               ),
//
//               const SizedBox(height: 10),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _onCartaoVirtualTap,
//                   child: const Text('Acessar Cartão Virtual'),
//                 ),
//               ),
//             ],
//           ),
//         ),  // dados login
//       ],
//
//       space,
//     ];
//   }
//
//   Widget _fotoTile() {
//     if (_image != null) {
//       return Image.file(File(_image!.path),
//         fit: BoxFit.cover,
//         errorBuilder: errorBuiler,
//       );
//     }
//
//     return FotoLayout(
//       path: model1.foto,
//       borderRadius: 0,
//       aspectRatio: 1/1.2,
//     );
//   }
//
//   @override
//   Future<bool> onSave() async {
//     return false;
//   }
//
//   @override
//   Future<bool> onRemove() async {
//     return false;
//   }
//
//   void _onCartaoVirtualTap() async {
//     try {
//       if (model1.emailUsuario.isEmpty) throw 'O email está vazio';
//       if (model1.codUsuario == 0) throw 'O código está vazio';
//       final ano = model1.dataNascimento?.year;
//       if (ano == null || ano < 1800) throw 'O ano de nascimento parece incorreto';
//     } catch(e) {
//       DialogBox(
//         context: context,
//         content: [
//           Text(e.toString()),
//         ],
//       ).ok();
//       return;
//     }
//
//     bool calcelar = false;
//
//     DialogBox(
//       context: context,
//       content: const [
//         Text('Obtendo dados do membro'),
//         SizedBox(height: 5),
//         LinearProgressIndicator(),
//       ],
//     ).cancel().then((value) {
//       calcelar = value.isNegative;
//     });
//
//     if (!CvProvider.i.containsCod(model1.codUsuario)) {
//       await CvProvider.i.login(model1.emailUsuario, '${model1.codUsuario}',
//           '${model1.dataNascimento?.year}');
//     }
//
//     if (!mounted) return;
//     if (calcelar) return;
//
//     Navigator.pop(context);
//
//     await Navigate.push(context, PerfilPage(membro: model1));
//   }
//
//
//   void _onNascChanged(String? value) {
//     final data = Formats.stringToDateTime(value!);
//     _anoNasc.text = '${data?.year ?? ''}';
//   }
//
//   void _onCargoChanged(int? value) {
//
//   }
// }

class MembroPage2 extends StatefulWidget {
  final Membro membro;
  final bool readOnly;
  const MembroPage2({
    super.key,
    required this.membro,
    this.readOnly = true,
  });

  @override
  State<StatefulWidget> createState() => _State2();
}
class _State2 extends StateItem<MembroPage2> {

  Membro get membro => widget.membro;
  bool get readOnly => widget.readOnly;

  bool get isNovo => membro.id.isEmpty;
  bool get meuPerfil => membro.id == FirebaseProvider.i.user.id;

  MembrosProvider provider = MembrosProvider.i;

  late final MaskedTextController _dateController = MaskedTextController(
    mask: Masks.date,
    text: membro.dtNascimento,
  );

  final _anoNasc = TextEditingController();

  XFile? _image;

  @override
  String get title => 'Membro';

  @override
  List<Widget> get formContent {
    const contentPadding = EdgeInsets.all(10);

    return [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _fotoTile(),
      ),  // foto

      Card(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            TextFormField(
              initialValue: membro.nomeUsuario,
              readOnly: true,
              keyboardType: TextInputType.name,
              inputFormatters: TextType.name.upperCase.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Nome',
                contentPadding: contentPadding,
              ),
              validator: Validators.obrigatorio,
              onSaved: (value) => membro.nomeUsuario = value!,
            ),  // nome

            AbsorbPointer(
              absorbing: true,
              child: DropdownButtonFormField(
                value: membro.codFuncao,
                items: Arrays.funcoes.keys.map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(Arrays.funcoes[e]!),
                )).toList(),
                decoration: const InputDecoration(
                  labelText: 'Cargo',
                  contentPadding: contentPadding,
                ),
                onChanged: _onCargoChanged,
              ),
            ),  // cargo

            TextFormField(
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Data de Nascimento',
                contentPadding: contentPadding,
              ),
              onSaved: (value) => membro.dtNascimento = value!,
              validator: Validators.dataObrigatorio,
              onChanged: _onNascChanged,
            ),  // nascimento
          ],
        ),
      ),  // dados

      const SizedBox(height: 10),

      Card(
        margin: EdgeInsets.zero,
        child: Column(
          children: [
            const Text('Endereço'),

            TextFormField(
              initialValue: membro.endereco,
              keyboardType: TextInputType.name,
              readOnly: true,
              inputFormatters: TextType.name.upperCase.inputFormatters,
              decoration: const InputDecoration(
                labelText: 'Endereço',
                contentPadding: contentPadding,
              ),
            ),
          ],
        ),
      ),  // Endereço

      if (!readOnly || meuPerfil)...[
        const SizedBox(height: 10),
        Card(
          margin: EdgeInsets.zero,
          color: Colors.white,
          child: Column(
            children: [
              const Text('Dados de login'),

              TextFormField(
                initialValue: membro.emailUsuario,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: TextType.emailAddress.lowerCase.inputFormatters,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  contentPadding: contentPadding,
                ),
                // validator: Validators.obrigatorio,
                onSaved: (value) => membro.emailUsuario = value!,
              ),  // email

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: membro.codUsuario.toString(),
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: TextType.numero.inputFormatters,
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        contentPadding: contentPadding,
                      ),
                      // validator: Validators.obrigatorio,
                      // onSaved: (value) => model1.codigo = value!,
                    ),
                  ),  // Código

                  SizedBox(
                    width: 140,
                    child: TextFormField(
                      controller: _anoNasc,
                      readOnly: true,
                      keyboardType: TextInputType.number,
                      inputFormatters: TextType.numero.inputFormatters,
                      decoration: const InputDecoration(
                        labelText: 'Ano Nascimento',
                        contentPadding: contentPadding,
                      ),
                    ),
                  ),  // ano
                ],
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onCartaoVirtualTap,
                  child: const Text('Acessar Cartão Virtual'),
                ),
              ),
            ],
          ),
        ),  // dados login
      ],
    ];
  }

  @override
  void initState() {
    super.initState();

    _onNascChanged(membro.dtNascimento);
  }

  @override
  void onSaveTap() async {}

  @override
  void onRemoveTap() async {}


  Widget _fotoTile() {
    if (_image != null) {
      return Image.file(File(_image!.path),
        fit: BoxFit.cover,
        errorBuilder: errorBuiler,
      );
    }

    return FotoLayout(
      path: membro.foto,
      borderRadius: 0,
      aspectRatio: 1/1.2,
    );
  }


  void _onCartaoVirtualTap() async {
    try {
      if (membro.emailUsuario.isEmpty) throw 'O email está vazio';
      if (membro.codUsuario == 0) throw 'O código está vazio';
      final ano = membro.dataNascimento?.year;
      if (ano == null || ano < 1800) throw 'O ano de nascimento parece incorreto';
    } catch(e) {
      DialogBox(
        context: context,
        content: [
          Text(e.toString()),
        ],
      ).ok();
      return;
    }

    bool calcelar = false;

    DialogBox(
      context: context,
      content: const [
        Text('Obtendo dados do membro'),
        SizedBox(height: 5),
        LinearProgressIndicator(),
      ],
    ).cancel().then((value) {
      calcelar = value.isNegative;
    });

    if (!CvProvider.i.containsCod(membro.codUsuario)) {
      await CvProvider.i.login(membro.emailUsuario, '${membro.codUsuario}',
          '${membro.dataNascimento?.year}');
    }

    if (!mounted) return;
    if (calcelar) return;

    Navigator.pop(context);

    await Navigate.push(context, PerfilPage(membro: membro));
  }


  void _onNascChanged(String? value) {
    final data = Formats.stringToDateTime(value!);
    _anoNasc.text = '${data?.year ?? ''}';
  }

  void _onCargoChanged(int? value) {

  }
}