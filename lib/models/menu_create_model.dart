class MenuCreate {
  final String name;
  final int branchId;
  final dynamic status; // Can be bool or int

  MenuCreate({
    required this.name,
    required this.branchId, 
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'branchId': branchId,
      'status': status is bool ? (status ? 1 : 0) : status, 
    };
  }
}