import 'package:flutter/material.dart';

import '../../models/deals/deal_model.dart';
import '../../ui/app_skin.dart';

Widget typeOfDealList(Deal deal) {
  Color color = AppColor.primaryColor;
  switch (deal.dealTypeOfDeal) {
    case 'discount':
      return Row(
        children: [
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      deal.dealAmount!,
                      style: TextStyle(
                          color: color, fontSize: AppFontSizes.titleSize + 10.0, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                    Column(children: [
                      Text(
                        '%',
                        style: TextStyle(color: color, fontSize: AppFontSizes.subTitleSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'OFF',
                        style: TextStyle(
                            color: color,
                            fontSize: AppFontSizes.contentSmallSize - 2.0,
                            height: 1.0,
                            fontFamily: "Matterdi",
                            fontWeight: FontWeight.w700),
                      ),
                    ]),
                  ],
                ),
              )),
          Flexible(
              flex: 2,
              child: Container(
                child: Text(
                  deal.dealTitle!,
                  style: TextStyle(color: color, fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
        ],
      );

    case 'dollar':
      return Row(
        children: [
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.subTitleSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style: TextStyle(
                          color: color, fontSize: AppFontSizes.titleSize + 10.0, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'OFF',
                      style: TextStyle(
                          color: color,
                          fontSize: AppFontSizes.contentSmallSize - 2.0,
                          height: 1.0,
                          fontFamily: "Matterdi",
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              )),
          Flexible(
              flex: 2,
              child: Container(
                child: Text(
                  deal.dealTitle!,
                  style: TextStyle(color: color, fontSize: AppFontSizes.contentSmallSize, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ))
        ],
      );

    case 'bogo':
      return Row(
        children: [
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'BOGO',
                          style: TextStyle(
                              color: color, fontSize: AppFontSizes.titleSize, height: 1.1, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'BUY 1 GET 1',
                          style: TextStyle(
                              color: color,
                              fontSize: AppFontSizes.contentSmallSize - 2.5,
                              height: 0.7,
                              fontFamily: "Matterdi",
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'FOR',
                        style: TextStyle(
                            color: color,
                            fontSize: AppFontSizes.contentSmallSize - 2.0,
                            height: 1.0,
                            fontFamily: "Matterdi",
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style:
                          TextStyle(color: color, fontSize: AppFontSizes.titleSize, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ))
        ],
      );

    case 'b2g1':
      return Row(
        children: [
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          'B2G1',
                          style: TextStyle(
                              color: color, fontSize: AppFontSizes.titleSize, height: 1.1, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'BUY 2 GET 1',
                          style: TextStyle(
                              color: color,
                              fontSize: AppFontSizes.contentSmallSize - 2.5,
                              height: 0.7,
                              fontFamily: "Matterdi",
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'FOR',
                        style: TextStyle(
                            color: color,
                            fontSize: AppFontSizes.contentSmallSize - 2.0,
                            height: 1.0,
                            fontFamily: "Matterdi",
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style:
                          TextStyle(color: color, fontSize: AppFontSizes.titleSize, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ))
        ],
      );

    case 'offer':
      return Row(
        children: [
          Flexible(
              flex: 2,
              child: Container(
                width: double.maxFinite,
                child: Text(
                  deal.dealOffer!,
                  style: TextStyle(
                      color: color,
                      fontSize: AppFontSizes.contentSmallSize - 1.0,
                      // fontFamily: "Matterdi",
                      fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
          Flexible(
              flex: 2,
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'FOR',
                        style: TextStyle(
                            color: color,
                            fontSize: AppFontSizes.contentSmallSize - 2.0,
                            height: 1.0,
                            fontFamily: "Matterdi",
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 2.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style: TextStyle(
                          color: color, fontSize: AppFontSizes.titleSize - 2.5, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ))
        ],
      );

    default:
      return Container();
  }
}

Widget typeOfDealDetail(Deal deal) {
  Color color = AppColor.fourthColor;
  switch (deal.dealTypeOfDeal) {
    case 'discount':
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              deal.dealAmount!,
              style:
                  TextStyle(color: color, fontSize: AppFontSizes.titleSize + 27.5, height: 1.3, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
            ),
            Column(children: [
              Text(
                '%',
                style: TextStyle(color: color, fontSize: AppFontSizes.subTitleSize + 15.0, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
              ),
              Text(
                'OFF',
                style: TextStyle(color: color, fontSize: AppFontSizes.subTitleSize, height: 0.5, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
              ),
            ]),
          ],
        ),
      );

    case 'dollar':
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                '\$',
                style: TextStyle(color: color, fontSize: AppFontSizes.subTitleSize + 2.5, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              deal.dealAmount!,
              style:
                  TextStyle(color: color, fontSize: AppFontSizes.titleSize + 27.5, height: 1.3, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
            ),
            Text(
              'OFF',
              style:
                  TextStyle(color: color, fontSize: AppFontSizes.contentSize - 1.5, fontFamily: "Matterdi", height: 0.5, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );

    case 'bogo':
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'BUY 1 GET 1',
                  style: TextStyle(
                      color: color, fontSize: AppFontSizes.titleSize - 5.0, height: 1.7, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'FOR',
                        style: TextStyle(
                            color: color, fontSize: AppFontSizes.contentSmallSize, height: 1.0, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style: TextStyle(
                          color: color, fontSize: AppFontSizes.titleSize + 2.5, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

    case 'b2g1':
      return Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'BUY 2 GET 1',
                  style: TextStyle(
                      color: color, fontSize: AppFontSizes.titleSize - 7.5, height: 1.7, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0),
                      child: Text(
                        'FOR',
                        style: TextStyle(
                            color: color, fontSize: AppFontSizes.contentSmallSize, height: 1.0, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '\$',
                        style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      deal.dealAmount!,
                      style: TextStyle(
                          color: color, fontSize: AppFontSizes.titleSize + 2.5, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

    case 'offer':
      return Container(
        padding: EdgeInsets.only(top: 3.5),
        child: Column(
          children: [
            Text(
              deal.dealOffer!,
              style: TextStyle(
                  color: color,
                  fontSize: deal.dealOffer!.length > 12 ? (AppFontSizes.titleSize - 14.0) : AppFontSizes.titleSize - 8.0,
                  fontFamily: "Matterdi",
                  fontWeight: FontWeight.w500),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Text(
                    'FOR',
                    style: TextStyle(
                        color: color,
                        fontSize: AppFontSizes.contentSmallSize - 1.0,
                        height: 1.0,
                        fontFamily: "Matterdi",
                        fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(width: 5.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '\$',
                    style: TextStyle(color: color, fontSize: AppFontSizes.contentSize, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  deal.dealAmount!,
                  style: TextStyle(
                      color: color, fontSize: AppFontSizes.titleSize + 2.5, height: 1.2, fontFamily: "Matterdi", fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      );

    default:
      return Container();
  }
}
