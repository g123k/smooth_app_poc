import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ValueListener<T> extends StatelessWidget {
  const ValueListener({
    required this.onValueChanged,
    required this.child,
    super.key,
  });

  final void Function(T) onValueChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Selector<T, T>(
      shouldRebuild: (T oldValue, T newValue) {
        onValueChanged(newValue);
        return false;
      },
      builder: (_, __, child) => child!,
      selector: (_, T value) => value,
      child: child,
    );
  }
}
