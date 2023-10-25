class ItemModel{
  int id;
  bool? sub;
  bool? arqueo;
  ItemModel( this.id,  this.title, {this.moneda, this.cambio, this.monedaId, this.sub, this.arqueo});
  int? monedaId;
  double? cambio;
  String title;
  String? moneda;
  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}

class ItemsClientModel{
  int id;
  String ruc;
  ItemsClientModel(this.id, this.title, this.ruc);

  String title;

  @override
  String toString() {
    // TODO: implement toString
    return title;
  }
}