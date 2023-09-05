import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ValueListener<Y extends ValueNotifier<X>, X> extends StatefulWidget {
  const ValueListener({
    required this.onValueChanged,
    required this.child,
    super.key,
  });

  final void Function(X) onValueChanged;
  final Widget child;

  @override
  State<ValueListener<Y, X>> createState() => _ValueListenerState<X, Y>();
}

class _ValueListenerState<X, Y extends ValueNotifier<X>>
    extends State<ValueListener<Y, X>> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<Y>()
      ..removeListener(_onValueChanged)
      ..addListener(_onValueChanged);
  }

  void _onValueChanged() {
    widget.onValueChanged(context.read<Y>().value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

extension ChangeNotifierExtension on ChangeNotifier {
  void replaceListener(VoidCallback listener) {
    removeListener(listener);
    addListener(listener);
  }
}
