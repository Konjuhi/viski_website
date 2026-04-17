import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import 'features/products/presentation/screens/storefront_screen.dart';

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      const StorefrontScreen(),
    ], classes: 'app');
  }
}
