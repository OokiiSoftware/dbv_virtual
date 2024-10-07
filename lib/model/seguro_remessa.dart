class SeguroRemessa {
  int codUsuario = 0;
  int codVida = 0;

  String nomeUsuario = '';
  String funcao = '';
  bool ativo;
  bool canDelete;

  String get foto => 'https://sg.sdasystems.org/cms/fotos_membros/$codUsuario.jpg';

  SeguroRemessa({
    required this.codUsuario,
    required this.codVida,
    required this.nomeUsuario,
    required this.funcao,
    required this.ativo,
    required this.canDelete,
  });
}