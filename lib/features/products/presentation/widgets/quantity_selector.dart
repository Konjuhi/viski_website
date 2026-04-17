import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class QuantitySelector extends StatelessComponent {
  const QuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final void Function() onIncrement;
  final void Function() onDecrement;

  @override
  Component build(BuildContext context) {
    return div([
      button(
        [Component.text('−')],
        classes: 'qty-btn',
        events: {'click': (_) => onDecrement()},
      ),
      span([Component.text('$quantity')], classes: 'qty-value'),
      button(
        [Component.text('+')],
        classes: 'qty-btn',
        events: {'click': (_) => onIncrement()},
      ),
    ], classes: 'quantity-selector');
  }
}
