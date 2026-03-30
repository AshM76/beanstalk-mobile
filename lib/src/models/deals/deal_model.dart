import '../stores/store_model.dart';

/// Deal class.
class Deal {
  Deal({
    this.dealId,
    this.dealTitle,
    this.dealDescription,
    this.dealImageUrl,
    this.dealTypeOfDeal,
    this.dealAmount,
    this.dealOffer,
    this.dealTypeOfProduct,
    this.dealBrandOfProduct,
    this.dealRangeDeal,
    this.dealStartDate,
    this.dealEndDate,
    this.dealUrl,
    this.dealStatus,
    this.dealDispensaryId,
    this.dealDispensaryName,
    this.dealStoresAvailables,
  });

  String? dealId;
  String? dealTitle;
  String? dealDescription;
  String? dealImageUrl;
  String? dealTypeOfDeal;
  String? dealAmount;
  String? dealOffer;
  String? dealTypeOfProduct;
  String? dealBrandOfProduct;
  String? dealRangeDeal;
  DateTime? dealStartDate;
  DateTime? dealEndDate;
  String? dealUrl;
  String? dealStatus;
  String? dealDispensaryId;
  String? dealDispensaryName;
  List<Store>? dealStoresAvailables;

  factory Deal.fromJsonWidgetList(Map<String, dynamic> parsedJson) {
    return new Deal(
      dealId: parsedJson['deal_id'] ?? "",
      dealTitle: parsedJson['deal_title'] ?? "",
      dealImageUrl: parsedJson['deal_imageURL'] ?? "",
      dealTypeOfDeal: parsedJson['deal_typeOfDeal'] ?? "",
      dealAmount: parsedJson['deal_amount'] ?? "",
      dealOffer: parsedJson['deal_offer'] ?? "",
    );
  }

  factory Deal.fromJson(Map<String, dynamic> parsedJson) {
    List<Store> storeListTemp = [];
    final storesResult = parsedJson['deal_stores_availables'] ?? [];
    storesResult.forEach((store) {
      Store tempStore = Store.fromJsonList(store);
      storeListTemp.add(tempStore);
    });

    return new Deal(
      dealId: parsedJson['deal_id'] ?? "",
      dealTitle: parsedJson['deal_title'] ?? "",
      dealDescription: parsedJson['deal_description'] ?? "",
      dealImageUrl: parsedJson['deal_imageURL'] ?? "",
      dealTypeOfDeal: parsedJson['deal_typeOfDeal'] ?? "",
      dealAmount: parsedJson['deal_amount'] ?? "",
      dealOffer: parsedJson['deal_offer'] ?? "",
      dealTypeOfProduct: parsedJson['deal_typeOfProduct'] ?? "",
      dealBrandOfProduct: parsedJson['deal_brandOfProduct'] ?? "",
      dealRangeDeal: parsedJson['deal_rangeDeal'] ?? "",
      dealStartDate: parsedJson['deal_startDate'] is Map
          ? DateTime.parse(parsedJson['deal_startDate']['value'])
          : DateTime.parse(parsedJson['deal_startDate']),
      dealEndDate: parsedJson['deal_endDate'] is Map
          ? DateTime.parse(parsedJson['deal_endDate']['value'])
          : DateTime.parse(parsedJson['deal_endDate']),
      dealUrl: parsedJson['deal_url'] ?? "",
      dealStatus: parsedJson['deal_status'] ?? "",
      dealDispensaryId: parsedJson['deal_dispensary_id'] ?? "",
      dealDispensaryName: parsedJson['deal_dispensary_name'] ?? "",
      dealStoresAvailables: storeListTemp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "deal_id": this.dealId,
      "deal_title": this.dealTitle,
      "deal_description": this.dealDescription,
      "deal_imageURL": this.dealImageUrl,
      "deal_typeOfDeal": this.dealTypeOfDeal,
      "deal_amount": this.dealAmount,
      "deal_offer": this.dealOffer,
      "deal_typeOfProduct": this.dealTypeOfProduct,
      "deal_brandOfProduct": this.dealBrandOfProduct,
      "deal_rangeDeal": this.dealRangeDeal,
      "deal_startDate": this.dealStartDate,
      "deal_endDate": this.dealEndDate,
      "deal_url": this.dealUrl,
      "deal_status": this.dealStatus,
      "deal_dispensary_id": this.dealDispensaryId,
      "deal_dispensary_name": this.dealDispensaryName,
      "deal_stores_availables": this.dealStoresAvailables
    };
  }
}
