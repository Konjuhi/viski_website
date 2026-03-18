import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../cart/domain/cart_item.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../products/domain/product.dart';
import '../../domain/create_order_item_request.dart';
import '../../domain/create_order_request.dart';
import '../providers/order_submission_controller.dart';

const _summarySurfaceColor = Color(0xFFF6F3EC);

class OrderFormSheet extends ConsumerStatefulWidget {
  const OrderFormSheet({
    super.key,
    required this.items,
    required this.productsById,
  });

  final List<CartItem> items;
  final Map<String, Product> productsById;

  @override
  ConsumerState<OrderFormSheet> createState() => _OrderFormSheetState();
}

class _OrderFormSheetState extends ConsumerState<OrderFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final request = CreateOrderRequest(
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      items: [
        for (final item in widget.items)
          CreateOrderItemRequest(
            productId: item.productId,
            quantity: item.quantity,
          ),
      ],
    );

    await ref
        .read(orderSubmissionControllerProvider.notifier)
        .submitOrder(request);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(orderSubmissionControllerProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (_) {
          if (previous?.isLoading ?? false) {
            ref.read(cartControllerProvider.notifier).clear();
            Navigator.of(context).pop(true);
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Order failed: $error')));
        },
      );
    });

    final theme = Theme.of(context);
    final isSubmitting = ref.watch(orderSubmissionControllerProvider).isLoading;
    final subtotal = widget.items.fold<double>(0, (sum, item) {
      final product = widget.productsById[item.productId];
      if (product == null) {
        return sum;
      }
      return sum + (product.price * item.quantity);
    });

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Complete your order',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  _CloseButton(
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.items.length} item${widget.items.length == 1 ? '' : 's'} in bag',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _summarySurfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order summary', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    for (final item in widget.items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.productsById[item.productId]?.name ??
                                    'Unavailable product',
                              ),
                            ),
                            Text(
                              'x${item.quantity} • ${formatPrice((widget.productsById[item.productId]?.price ?? 0) * item.quantity)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 2) {
                    return 'Enter the customer name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Phone number'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 8) {
                    return 'Enter a valid phone number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Delivery address',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.length < 8) {
                    return 'Enter the address for confirmation.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _summarySurfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimated total', style: theme.textTheme.titleMedium),
                    Text(
                      formatPrice(subtotal),
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                child: Text(
                  isSubmitting ? 'Submitting order...' : 'Submit order',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black),
        ),
        child: const Icon(Icons.close, size: 20, color: Colors.black),
      ),
    );
  }
}
