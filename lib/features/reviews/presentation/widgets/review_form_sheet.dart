import 'dart:html' as html;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr/dom.dart';

import '../../../../core/utils/form_validators.dart';
import '../../../../services/supabase_service.dart';
import '../../../products/domain/product.dart';
import '../../../reviews/data/supabase_review_repository.dart';
import '../../domain/create_product_review_request.dart';

class ReviewFormSheet extends StatefulComponent {
  const ReviewFormSheet({
    super.key,
    required this.product,
    required this.onClose,
    required this.onSuccess,
  });

  final Product product;
  final void Function() onClose;
  final void Function() onSuccess;

  @override
  State<ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<ReviewFormSheet> {
  int _rating = 5;
  String _name = '';
  String _reviewText = '';
  String? _nameError;
  String? _reviewError;
  bool _submitting = false;
  String? _submitError;

  bool _validate() {
    final errors = validateReviewForm(name: _name, reviewText: _reviewText);
    setState(() {
      _nameError = errors.name;
      _reviewError = errors.reviewText;
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
      final repo = SupabaseReviewRepository(SupabaseService.client);
      await repo.submitReview(
        CreateProductReviewRequest(
          productId: component.product.id,
          customerName: _name.trim(),
          rating: _rating,
          reviewText: _reviewText.trim(),
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
          p([Component.text('Write a review')], classes: 'modal-title'),
          button(
            [Component.text('✕')],
            classes: 'modal-close',
            events: {'click': (_) => component.onClose()},
          ),
        ], classes: 'modal-header-row'),
        p(
          [Component.text(component.product.name)],
          classes: 'product-description',
          styles: Styles(raw: {'margin-bottom': '8px'}),
        ),
        div(
          [
            p(
              [Component.text('Your rating')],
              classes: 'form-label',
              styles: Styles(raw: {'margin-bottom': '8px'}),
            ),
            div(
              List.generate(5, (i) {
                final starNum = i + 1;
                return button(
                  [
                    span(
                      [Component.text('★')],
                      classes: starNum <= _rating ? 'star-filled' : 'star-empty',
                    ),
                  ],
                  events: {'click': (_) => setState(() => _rating = starNum)},
                );
              }),
              classes: 'star-selector',
            ),
          ],
          styles: Styles(raw: {'margin-bottom': '16px'}),
        ),
        div(
          [
            label([Component.text('Your name')], classes: 'form-label'),
            input(
              type: InputType.text,
              value: _name,
              attributes: const {'placeholder': 'Your name'},
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
            label([Component.text('Your review')], classes: 'form-label'),
            textarea(
              [Component.text(_reviewText)],
              placeholder: 'Share your thoughts…',
              rows: 4,
              classes: 'form-input${_reviewError != null ? ' error' : ''}',
              events: {
                'input': (e) {
                  final v = (e.target as html.TextAreaElement).value ?? '';
                  setState(() {
                    _reviewText = v;
                    if (_reviewError != null) _reviewError = null;
                  });
                },
              },
            ),
            if (_reviewError != null)
              span([Component.text(_reviewError!)], classes: 'form-error'),
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
          [Component.text(_submitting ? 'Submitting…' : 'Submit review')],
          classes: 'btn-primary',
          events: {'click': (_) => _submit()},
        ),
      ],
      classes: 'modal-shell',
      events: {'click': (e) => e.stopPropagation()},
    );
  }
}
