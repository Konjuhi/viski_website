import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

class FeatureHighlightCard extends StatelessComponent {
  const FeatureHighlightCard({
    super.key,
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Component build(BuildContext context) {
    return div([
      p([Component.text(title)], classes: 'feature-card-title'),
      p([Component.text(description)], classes: 'feature-card-desc'),
    ], classes: 'feature-card');
  }
}
