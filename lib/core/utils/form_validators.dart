class OrderFormErrors {
  const OrderFormErrors({this.name, this.phone, this.address});
  final String? name;
  final String? phone;
  final String? address;
  bool get isValid => name == null && phone == null && address == null;
}

OrderFormErrors validateOrderForm({
  required String name,
  required String phone,
  required String address,
}) {
  return OrderFormErrors(
    name: name.trim().length < 2 ? 'Enter your full name.' : null,
    phone: phone.trim().length < 8 ? 'Enter a valid phone number.' : null,
    address: address.trim().length < 8 ? 'Enter a delivery address.' : null,
  );
}

class ReviewFormErrors {
  const ReviewFormErrors({this.name, this.reviewText});
  final String? name;
  final String? reviewText;
  bool get isValid => name == null && reviewText == null;
}

ReviewFormErrors validateReviewForm({
  required String name,
  required String reviewText,
}) {
  return ReviewFormErrors(
    name: name.trim().length < 2 ? 'Enter your name.' : null,
    reviewText: reviewText.trim().length < 6 ? 'Write a short review.' : null,
  );
}
