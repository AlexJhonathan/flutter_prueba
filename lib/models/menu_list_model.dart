class Menu {
  final int id;
  final String name;
  final bool status;
  final int branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  List<MenuProduct> products;

  Menu({
    required this.id,
    required this.name,
    required this.status,
    required this.branchId,
    this.createdAt,
    this.updatedAt,
    this.products = const [],
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      branchId: json['branchId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      products: (json['products'] as List<dynamic>?)
              ?.map((item) => MenuProduct.fromJson(item))
              .toList() ?? [],
    );
  }
}

class MenuProduct {
  final int id;
  final int menuId;
  final int productId;
  final String createdAt;
  final String updatedAt;
  final dynamic deletedAt;
  final Map<String, dynamic>? product;

  MenuProduct({
    required this.id,
    required this.menuId,
    required this.productId,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.product,
  });

  factory MenuProduct.fromJson(Map<String, dynamic> json) {
    return MenuProduct(
      id: json['id'],
      menuId: json['menuId'],
      productId: json['productId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      deletedAt: json['deletedAt'],
      product: json['Product'] != null ? Map<String, dynamic>.from(json['Product']) : null,
    );
  }
}