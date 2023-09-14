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

    context.read<Y>().replaceListener(_onValueChanged);
  }

  void _onValueChanged() {
    widget.onValueChanged(context.read<Y>().value);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class ChangeListener<X extends ChangeNotifier> extends StatefulWidget {
  const ChangeListener({
    required this.onValueChanged,
    required this.child,
    super.key,
  });

  final VoidCallback onValueChanged;
  final Widget child;

  @override
  State<ChangeListener<X>> createState() => _ChangeListenerState<X>();
}

class _ChangeListenerState<X extends ChangeNotifier>
    extends State<ChangeListener<X>> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    context.read<X>().replaceListener(_onValueChanged);
  }

  void _onValueChanged() {
    widget.onValueChanged();
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

abstract class DistinctValueNotifier<T> extends ValueNotifier<T> {
  DistinctValueNotifier(T value) : super(value);

  @override
  set value(T newValue) {
    if (newValue != value) {
      super.value = newValue;
    }
  }
}
