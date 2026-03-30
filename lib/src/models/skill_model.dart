class Therapeutic {
  Therapeutic({
    this.kind,
    this.method,
    this.parameters,
    this.productBrand,
    this.productName,
    this.productDosage,
    this.productMeasurement,
  });

  String? kind; // cannabis / noncannabis
  String? method;
  String? parameters;
  String? productBrand;
  String? productName;
  String? productDosage;
  String? productMeasurement;

  factory Therapeutic.fromJson(Map<String, dynamic> parsedJson) {
    return new Therapeutic(
        kind: parsedJson['therapeutic_kind'] ?? "",
        method: parsedJson['therapeutic_method'] ?? "",
        parameters: parsedJson['therapeutic_parameters'] ?? "",
        productBrand: parsedJson['therapeutic_product_brand'] ?? "",
        productName: parsedJson['therapeutic_product_name'] ?? "",
        productDosage: parsedJson['therapeutic_product_dosage'] ?? "",
        productMeasurement: parsedJson['therapeutic_product_measurement'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      "therapeutic_kind": this.kind,
      "therapeutic_method": this.method,
      "therapeutic_parameters": this.parameters,
      "therapeutic_product_brand": this.productBrand,
      "therapeutic_product_name": this.productName,
      "therapeutic_product_dosage": this.productDosage,
      "therapeutic_product_measurement": this.productMeasurement,
    };
  }
}
