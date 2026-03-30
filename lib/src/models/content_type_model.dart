class DeliveryMethod {
  DeliveryMethod({
    this.title,
    this.isSelected = false,
  });

  String? title;
  bool isSelected;

  factory DeliveryMethod.fromJson(Map<String, dynamic> parsedJson) {
    return new DeliveryMethod(
      title: parsedJson['deliveryMethodType_title'] ?? "",
      isSelected: parsedJson['deliveryMethodType_isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "deliveryMethodType_title": this.title,
      "deliveryMethodType_isSelected": this.isSelected,
    };
  }
}
