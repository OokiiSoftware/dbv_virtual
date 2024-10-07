class SaudeGrafico {
  String title = '';
  Map<String, int> values = {};

  SaudeGrafico({
    this.title = '',
    this.values = const {},
  });

  @override
  String toString() => {
    'title': title,
    'values': values,
  }.toString();
}