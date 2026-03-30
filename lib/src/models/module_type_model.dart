class ProductType {
  ProductType({
    this.title,
    this.description,
    this.icon,
    this.isSelected = false,
  });

  String? title;
  String? description;
  String? icon;
  bool isSelected;

  factory ProductType.fromJson(Map<String, dynamic> parsedJson) {
    return new ProductType(
        title: parsedJson['productType_title'] ?? "",
        description: parsedJson['productType_description'] ?? "",
        icon: parsedJson['productType_icon'] ?? "",
        isSelected: parsedJson['productType_isSelected'] ?? false);
  }

  Map<String, dynamic> toJson() {
    return {
      "productType_title": this.title,
      "productType_description": this.description,
      "productType_icon": this.icon,
      "productType_isSelected": this.isSelected,
    };
  }
}
