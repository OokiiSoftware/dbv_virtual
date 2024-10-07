abstract class ItemModel {
  String get id;

  Map<String, dynamic> toJson();
}

abstract class ItemModel2 extends ItemModel {
  int get ano;
}