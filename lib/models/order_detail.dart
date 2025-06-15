class OrderDetail {
  final int orderId;
  final List<DetailItem> details;

  OrderDetail({
    required this.orderId,
    required this.details,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    List<DetailItem> detailsList = [];
    if (json['details'] != null) {
      detailsList = List<DetailItem>.from(
        (json['details'] as List).map((item) => DetailItem.fromJson(item))
      );
    }

    return OrderDetail(
      orderId: json['orderId'],
      details: detailsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'details': details.map((detail) => detail.toJson()).toList(),
    };
  }
}

class DetailItem {
  final int productId;
  final int quantity;
  
  // Campos opcionales que pueden ser necesarios según tu API
  final double? price;
  final String? notes;
  final int? detailId; // Para cuando se recupera de la API

  DetailItem({
    required this.productId,
    required this.quantity,
    this.price,
    this.notes,
    this.detailId,
  });

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price']?.toDouble(),
      notes: json['notes'],
      detailId: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'productId': productId,
      'quantity': quantity,
    };
    
    if (price != null) data['price'] = price;
    if (notes != null) data['notes'] = notes;
    if (detailId != null) data['id'] = detailId;
    
    return data;
  }
}