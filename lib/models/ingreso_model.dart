class IngresoModel{
  String cuenta;
  String estado;
  String comentario;
  String comprobante;
  String moneda;
  String cuotas;
  String cambio;
  String montoOrigen;
  String debe;
  String haber;

  IngresoModel(
      this.cuenta,
      this.estado,
      this.comentario,
      this.comprobante,
      this.moneda,
      this.cuotas,
      this.cambio,
      this.montoOrigen,
      this.debe,
      this.haber,
      this.vencimiento);

  String vencimiento;
}