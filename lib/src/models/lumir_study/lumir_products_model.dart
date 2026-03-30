import '../canna_cannabinoid_model.dart';
import '../canna_terpene_model.dart';

/// Inventory-Product class.
class LumirProduct {
  LumirProduct({
    this.id,
    this.name,
    this.description,
    this.productType,
    this.deliveryMethod,
    this.specie,
    this.strain,
    this.size,
    this.origin,
    this.ingredientUnit,
    this.cannabinoids,
    this.terpenes,
    this.country,
    this.state,
    this.isSelected = false,
  });

  String? id;
  String? name;
  String? description;
  // String consumptionMethod;
  String? productType;
  String? deliveryMethod;
  String? specie;
  String? strain;
  String? size;
  String? origin;
  String? ingredientUnit;
  List<Cannabinoid>? cannabinoids;
  List<Terpene>? terpenes;
  List<String>? country;
  List<String>? state;
  bool isSelected;

  factory LumirProduct.fromJson(Map<String, dynamic> parsedJson) {
    List<Cannabinoid> cannabinoidsListTemp = [];
    final cannabinoidsResult = parsedJson['product_cannabinoid'] ?? [];
    cannabinoidsResult.forEach((cannabinoid) {
      Cannabinoid tempCannabinoid = Cannabinoid.fromLumirJson(cannabinoid);
      cannabinoidsListTemp.add(tempCannabinoid);
    });

    List<Terpene> terpenesListTemp = [];
    final terpenesResult = parsedJson['product_terpenes'] ?? [];
    terpenesResult.forEach((terpene) {
      Terpene tempTerpene = Terpene.fromLumirJson(terpene);
      terpenesListTemp.add(tempTerpene);
    });

    List<String> countriesListTemp = [];
    final contriesResult = parsedJson['product_country_available'] ?? [];
    contriesResult.forEach((country) {
      countriesListTemp.add(country);
    });

    List<String> statesListTemp = [];
    final statesResult = parsedJson['product_state_available'] ?? [];
    statesResult.forEach((state) {
      statesListTemp.add(state);
    });

    return new LumirProduct(
      id: parsedJson['product_id'] ?? "",
      name: parsedJson['product_name'] ?? "",
      description: parsedJson['product_description'] ?? "",
      productType: parsedJson['product_product_type'] ?? "",
      deliveryMethod: parsedJson['product_delivery_method'] ?? "",
      specie: parsedJson['product_specie'] ?? "",
      strain: parsedJson['product_strain'] ?? "",
      size: parsedJson['product_size'] ?? "",
      origin: parsedJson['product_origin'] ?? "",
      ingredientUnit: parsedJson['product_ingredients_unit'] ?? "",
      cannabinoids: cannabinoidsListTemp,
      terpenes: terpenesListTemp,
      country: countriesListTemp,
      state: statesListTemp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_id": this.id,
      "product_name": this.name,
      "product_description": this.description,
      "product_product_method": this.productType,
      "product_delivery_method": this.deliveryMethod,
      "product_specie": this.specie,
      "product_strain": this.strain,
      "product_size": this.size,
      "product_origin": this.origin,
      "product_ingredients_unit": this.ingredientUnit,
      "product_cannabinoid": this.cannabinoids,
      "product_terpenes": this.terpenes,
      "product_country_available": this.country,
      "product_state_available": this.state,
    };
  }
}
