class BarcodeUtils {
  const BarcodeUtils._();

  static bool isABarcode(String barcode) {
    return int.tryParse(barcode) != null &&
        barcode.length >= 8 &&
        barcode.length <= 13;
  }
}
