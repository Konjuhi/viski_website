import 'package:flutter/material.dart';

import '../core/config/supabase_config.dart';
import '../core/theme/app_theme.dart';
import '../features/products/presentation/screens/storefront_screen.dart';
import 'supabase_setup_screen.dart';

class SwiftShopApp extends StatelessWidget {
  const SwiftShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftShop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: SupabaseConfig.isConfigured
          ? const StorefrontScreen()
          : const SupabaseSetupScreen(),
    );
  }
}
