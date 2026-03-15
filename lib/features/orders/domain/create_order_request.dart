import 'create_order_item_request.dart';

class CreateOrderRequest {
  const CreateOrderRequest({
    required this.customerName,
    required this.phone,
    required this.address,
    required this.items,
  });

  final String customerName;
  final String phone;
  final String address;
  final List<CreateOrderItemRequest> items;

  Map<String, dynamic> toJson() {
    return {
      'customer_name_input': customerName,
      'phone_input': phone,
      'address_input': address,
      'items_input': items.map((item) => item.toJson()).toList(),
    };
  }
}
