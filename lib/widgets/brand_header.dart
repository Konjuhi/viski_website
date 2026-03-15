import 'package:flutter/material.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({
    super.key,
    required this.cartCount,
    required this.onCartTap,
  });

  final int cartCount;
  final VoidCallback onCartTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget iconShell(IconData icon) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 18, color: theme.colorScheme.onSurface),
      );
    }

    Widget cartButton() {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onCartTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            iconShell(Icons.shopping_bag_outlined),
            if (cartCount > 0)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 22,
                    minHeight: 22,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$cartCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Text(
          'SWIFTSHOP',
          style: theme.textTheme.titleLarge?.copyWith(letterSpacing: 1.2),
        ),
        const Spacer(),
        cartButton(),
      ],
    );
  }
}
