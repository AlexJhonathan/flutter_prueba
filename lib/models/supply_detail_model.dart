class SupplyDetail {
  final int id;
  final int supplyId;
  final int branchId;
  final int userId;
  final double purchased;
  final double consumed;
  final double remaining;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;
  final Supply supply;

  SupplyDetail({
    required this.id,
    required this.supplyId,
    required this.branchId,
    required this.userId,
    required this.purchased,
    required this.consumed,
    required this.remaining,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.supply,
  });

  factory SupplyDetail.fromJson(Map<String, dynamic> json) {
    return SupplyDetail(
      id: json['id'],
      supplyId: json['supplyId'],
      branchId: json['branchId'],
      userId: json['userId'],
      purchased: (json['purchased'] as num).toDouble(),
      consumed: (json['consumed'] as num).toDouble(),
      remaining: (json['remaining'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
      supply: Supply.fromJson(json['Supply']),
    );
  }
}

class Supply {
  final int id;
  final String name;
  final String unit;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic deletedAt;

  Supply({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: json['id'],
      name: json['name'],
      unit: json['unit'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      deletedAt: json['deletedAt'],
    );
  }
}