/// Inventory-Product class.
class Product {
  Product({
    this.id,
    this.name,
    this.description,
    this.dispensaryId,
    this.dispensaryName,
    this.flowerType,
    this.weight,
    this.weightUnit,
    this.thc,
    this.cbd,
    this.concentrateType,
    this.typeId,
    this.typeName,
    this.strainId,
    this.strainName,
    this.brandId,
    this.brandName,
  });

  String? id;
  String? name;
  String? description;
  String? dispensaryId;
  String? dispensaryName;
  String? flowerType;
  String? weight;
  String? weightUnit;
  String? thc;
  String? cbd;
  String? concentrateType;
  String? typeId;
  String? typeName;
  String? strainId;
  String? strainName;
  String? brandId;
  String? brandName;

  factory Product.fromJson(Map<String, dynamic> parsedJson) {
    return new Product(
      id: parsedJson['product_id'] ?? "",
      name: parsedJson['product_name'] ?? "",
      description: parsedJson['product_description'] ?? "",
      dispensaryId: parsedJson['dispensary_id'].toString(),
      dispensaryName: parsedJson['dispensary_name'] ?? "",
      flowerType: parsedJson['product_flower_type'] ?? "",
      weight: parsedJson['product_weight'].toString(),
      weightUnit: parsedJson['product_weight_unit'] ?? "",
      thc: parsedJson['product_thc_percentage'].toString(),
      cbd: parsedJson['product_cbd_percentage'].toString(),
      concentrateType: parsedJson['product_concentrate_type'] ?? "",
      typeId: parsedJson['product_type_id'] ?? "",
      typeName: parsedJson['product_type_name'] ?? "",
      strainId: parsedJson['strain_id'] ?? "",
      strainName: parsedJson['strain_name'] ?? "",
      brandId: parsedJson['brand_id'] ?? "",
      brandName: parsedJson['brand_name'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": this.id,
      "product_name": this.name,
      "product_description": this.description,
      "product_dispensary_id": this.dispensaryId,
      "product_dispensary_name": this.dispensaryName,
      "product_flower_type": this.flowerType,
      "product_weight": this.weight,
      "product_weight_unit": this.weightUnit,
      "product_thc_porcentage": this.thc,
      "product_cbd_porcentage": this.cbd,
      "product_concentrate_type": this.concentrateType,
      "product_type_id": this.typeId,
      "product_type_name": this.typeName,
      "product_strain_id": this.typeId,
      "product_strain_name": this.typeName,
      "product_brand_id": this.brandId,
      "product_brand_name": this.brandName,
    };
  }
}
