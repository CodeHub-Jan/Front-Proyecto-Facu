class AsientoManualItem{
  int cuentaId;

  AsientoManualItem(
      this.cuentaId,
      this.cuenta,
      this.comentario,
      this.comprobante,
      this.moneda,
      this.montoDeudor,
      this.montoAcreedor,
      this.cambio);

  String cuenta;
  String comentario;
  String comprobante;
  String moneda;
  String montoDeudor;
  String montoAcreedor;
  String cambio;
}