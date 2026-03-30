import 'package:flutter/material.dart';

import '../../models/deals/deal_model.dart';
import '../../services/setup_service.dart';
import 'deals_typeOfDeal_widget.dart';

Widget loadDealsList(BuildContext context, List<Deal> deals) {
  final size = MediaQuery.of(context).size;
  final String _urlResources = SetupServices.resourcesURL;
  return Container(
    child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: deals.length > 0 ? deals.length : 0,
        itemBuilder: (BuildContext context, int index) {
          final deal = deals[index];
          return Padding(
            padding: EdgeInsets.only(top: 2.5, bottom: 2.5, right: size.width * 0.025),
            child: Stack(
              children: [
                InkWell(
                  child: Material(
                    elevation: 2.5,
                    borderRadius: BorderRadius.circular(size.width * 0.05),
                    child: Container(
                        width: size.width * 0.45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(size.width * 0.025),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: double.maxFinite,
                                  height: 75.0,
                                  margin: EdgeInsets.only(bottom: size.width * 0.015),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(size.width * 0.025), topRight: Radius.circular(size.width * 0.025)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(size.width * 0.025), topRight: Radius.circular(size.width * 0.025)),
                                    child: Image.network(
                                      _urlResources + deal.dealImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: double.maxFinite,
                                  height: 40,
                                  child: typeOfDealList(deal),
                                )
                              ],
                            ),
                          ],
                        )),
                  ),
                  onTap: () {
                    print(deals[index].dealId);

                    // Navigator.push(
                    //   context,
                    //   SlideTopTransition(transitionTo: DealsDetailPage()),
                    // );

                    Navigator.pushNamed(context, 'deals_detail', arguments: deals[index].dealId);
                  },
                ),
                index == deals.length - 1 ? SizedBox(width: size.width * 0.575) : Container(),
              ],
            ),
          );
        }),
  );
}
