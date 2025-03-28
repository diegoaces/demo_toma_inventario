class ItemAjuste {
  String codigoProducto;
  int cantidadFisica1;
  int cantidadFisica2;
  String codigoEmpresa;
  String codigoSucursal;
  String codigoBodega;

  ItemAjuste({
    required this.codigoProducto,
    required this.cantidadFisica1,
    required this.cantidadFisica2,
    required this.codigoEmpresa,
    required this.codigoSucursal,
    required this.codigoBodega,
  });

  @override
  String toString() {
    return '$codigoProducto,$cantidadFisica1,$cantidadFisica2,$codigoEmpresa,$codigoSucursal,$codigoBodega';
  }
}
