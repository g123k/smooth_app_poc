import 'package:flutter/cupertino.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smoothapp_poc/utils/barcode_utils.dart';

class CameraViewStateManager extends ValueNotifier<CameraViewState> {
  CameraViewStateManager() : super(const CameraViewNoBarcodeState());

  String? _barcode;

  Future<void> onBarcodeDetected(String barcode) async {
    if (_barcode == barcode) {
      return;
    }

    if (BarcodeUtils.isABarcode(barcode)) {
      _barcode = barcode;
      value = CameraViewLoadingBarcodeState(barcode);

      try {
        OpenFoodAPIConfiguration.userAgent = UserAgent(name: 'OFF Poc');
        final ProductResultV3 product = await OpenFoodAPIClient.getProductV3(
          ProductQueryConfiguration(barcode, version: ProductQueryVersion.v3),
        );

        if (product.product == null || product.product!.nutriscore == null) {
          value = CameraViewUnknownProductState(barcode);
        } else {
          value = CameraViewProductAvailableState(product.product!);
        }
      } catch (_) {
        value = CameraViewErrorBarcodeState(barcode);
      }
    } else {
      value = CameraViewInvalidBarcodeState(barcode);
    }
  }

  void reset() {
    value = const CameraViewNoBarcodeState();
    _barcode = null;
  }

  String? get currentBarcode => _barcode;

  static CameraViewStateManager of(BuildContext context) {
    return context.read<CameraViewStateManager>();
  }
}

sealed class CameraViewState {
  const CameraViewState._();
}

class CameraViewNoBarcodeState extends CameraViewState {
  const CameraViewNoBarcodeState() : super._();
}

class CameraViewLoadingBarcodeState extends CameraViewState {
  final String barcode;

  const CameraViewLoadingBarcodeState(this.barcode) : super._();
}

class CameraViewErrorBarcodeState extends CameraViewState {
  final String barcode;

  const CameraViewErrorBarcodeState(this.barcode) : super._();
}

class CameraViewInvalidBarcodeState extends CameraViewState {
  final String barcode;

  const CameraViewInvalidBarcodeState(this.barcode) : super._();
}

class CameraViewProductAvailableState extends CameraViewState {
  final Product product;

  const CameraViewProductAvailableState(this.product) : super._();
}

class CameraViewIncompleteProductState extends CameraViewState {
  final String barcode;

  const CameraViewIncompleteProductState(this.barcode) : super._();
}

class CameraViewUnknownProductState extends CameraViewState {
  final String barcode;

  const CameraViewUnknownProductState(this.barcode) : super._();
}
