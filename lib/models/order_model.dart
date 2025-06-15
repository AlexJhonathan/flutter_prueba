// models/order.dart
class Order {
  int? id;          // Null cuando se está creando un nuevo pedido
  int tableId;
  int waiterId;
  int branchId;
  String date;
  String? notes;
  double total;
  int status;
  int? cookId;      // Null hasta que un cocinero acepte

  Order({
    this.id,
    required this.tableId,
    required this.waiterId,
    required this.branchId,
    required this.date,
    this.notes,
    required this.total,
    required this.status,
    this.cookId,
  });

  Map<String, dynamic> toJson() {
    return {
      'tableId': tableId,
      'waiterId': waiterId,
      'branchId': branchId,
      'date': date,
      'notes': notes ?? '',
      'total': total,
      'status': status,
      if (cookId != null) 'cookId': cookId,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['tableId'],
      waiterId: json['waiterId'],
      branchId: json['branchId'],
      date: json['date'],
      notes: json['notes'],
      total: json['total'],
      status: json['status'],
      cookId: json['cookId'],
    );
  }
}