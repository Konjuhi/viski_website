import 'dart:html' as html;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/form_validators.dart';
import '../../../../services/supabase_service.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../orders/data/supabase_order_repository.dart';
import '../../../orders/domain/create_order_item_request.dart';
import '../../../orders/domain/create_order_request.dart';
import '../../../products/domain/product.dart';

class OrderFormSheet extends StatefulComponent {
  const OrderFormSheet({
    super.key,
    required this.cart,
    required this.productsById,
    required this.onClose,
    required this.onSuccess,
  });

  final List<CartItem> cart;
  final Map<String, Product> productsById;
  final void Function() onClose;
  final void Function() onSuccess;

  @override
  State<OrderFormSheet> createState() => _OrderFormSheetState();
}

class _OrderFormSheetState extends State<OrderFormSheet> {
  String _name = '';
  String _phone = '';
  String _address = '';
  String? _nameError;
  String? _phoneError;
  String? _addressError;
  bool _submitting = false;
  String? _submitError;

  double get _subtotal => component.cart.fold(0, (sum, item) {
        final p = component.productsById[item.productId];
        return sum + (p?.price ?? 0) * item.quantity;
      });

  bool _validate() {
    final errors = validateOrderForm(name: _name, phone: _phone, address: _address);
    setState(() {
      _nameError = errors.name;
      _phoneError = errors.phone;
      _addressError = errors.address;
    });
    return errors.isValid;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final repo = SupabaseOrderRepository(SupabaseService.client);
      await repo.createOrder(
        CreateOrderRequest(
          customerName: _name.trim(),
          phone: _phone.trim(),
          address: _address.trim(),
          items: component.cart
              .map((i) =>
                  CreateOrderItemRequest(productId: i.productId, quantity: i.quantity))
              .toList(),
        ),
      );
      component.onSuccess();
    } catch (e) {
      setState(() {
        _submitting = false;
        _submitError = e.toString();
      });
    }
  }

  @override
  Component build(BuildContext context) {
    return div(
      [
        div([
          p([Component.text('Complete your order')], classes: 'modal-title'),
          button(
            [Component.text('✕')],
            classes: 'modal-close',
            events: {'click': (_) => component.onClose()},
          ),
        ], classes: 'modal-header-row'),
        div(
          [
            p([Component.text('Order summary')], classes: 'order-summary-title'),
            ...component.cart.map((item) {
              final p = component.productsById[item.productId];
              return div(
                [
                  span([Component.text(p?.name ?? 'Unavailable')]),
                  span([
                    Component.text('x${item.quantity} · ${formatPrice((p?.price ?? 0) * item.quantity)}'),
                  ]),
                ],
                classes: 'order-summary-item',
              );
            }),
            div(
              [
                span([Component.text('Total')]),
                span([Component.text(formatPrice(_subtotal))]),
              ],
              classes: 'order-summary-total',
            ),
          ],
          classes: 'order-summary',
        ),
        div(
          [
            label([Component.text('Full name')], classes: 'form-label'),
            input(
              type: InputType.text,
              value: _name,
              attributes: const {'placeholder': 'Your full name'},
              classes: 'form-input${_nameError != null ? ' error' : ''}',
              events: {
                'input': (e) {
                  final v = (e.target as html.InputElement).value ?? '';
                  setState(() {
                    _name = v;
                    if (_nameError != null) _nameError = null;
                  });
                },
              },
            ),
            if (_nameError != null)
              span([Component.text(_nameError!)], classes: 'form-error'),
          ],
          classes: 'form-group',
        ),
        div(
          [
            label([Component.text('Phone number')], classes: 'form-label'),
            input(
              type: InputType.tel,
              value: _phone,
              attributes: const {'placeholder': 'Your phone number'},
              classes: 'form-input${_phoneError != null ? ' error' : ''}',
              events: {
                'input': (e) {
                  final v = (e.target as html.InputElement).value ?? '';
                  setState(() {
                    _phone = v;
                    if (_phoneError != null) _phoneError = null;
                  });
                },
              },
            ),
            if (_phoneError != null)
              span([Component.text(_phoneError!)], classes: 'form-error'),
          ],
          classes: 'form-group',
        ),
        div(
          [
            label([Component.text('Delivery address')], classes: 'form-label'),
            textarea(
              [Component.text(_address)],
              placeholder: 'Street, city, postal code',
              rows: 3,
              classes: 'form-input${_addressError != null ? ' error' : ''}',
              events: {
                'input': (e) {
                  final v = (e.target as html.TextAreaElement).value ?? '';
                  setState(() {
                    _address = v;
                    if (_addressError != null) _addressError = null;
                  });
                },
              },
            ),
            if (_addressError != null)
              span([Component.text(_addressError!)], classes: 'form-error'),
          ],
          classes: 'form-group',
        ),
        if (_submitError != null)
          p(
            [Component.text('Error: $_submitError')],
            classes: 'form-error',
            styles: Styles(raw: {'margin-bottom': '12px'}),
          ),
        button(
          [Component.text(_submitting ? 'Submitting…' : 'Submit order')],
          classes: 'btn-primary',
          events: {'click': (_) => _submit()},
        ),
      ],
      classes: 'modal-shell',
      events: {'click': (e) => e.stopPropagation()},
    );
  }
}
