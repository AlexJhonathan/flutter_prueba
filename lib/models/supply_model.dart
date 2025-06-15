class Supply {
  final int id;
  final int supplyId;
  final int branchId;
  final int userId;
  final double purchased;
  final double consumed;
  final double remaining;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Supply({
    required this.id,
    required this.supplyId,
    required this.branchId,
    required this.userId,
    required this.purchased,
    required this.consumed,
    required this.remaining,
    this.createdAt,
    this.updatedAt,
  });

  factory Supply.fromJson(Map<String, dynamic> json) {
    return Supply(
      id: json['id'] ?? 0,
      supplyId: json['supplyId'] ?? 0,
      branchId: json['branchId'] ?? 0,
      userId: json['userId'] ?? 0,
      purchased: (json['purchased'] ?? 0).toDouble(),
      consumed: (json['consumed'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplyId': supplyId,
      'branchId': branchId,
      'userId': userId,
      'purchased': purchased,
      'consumed': consumed,
      'remaining': remaining,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}