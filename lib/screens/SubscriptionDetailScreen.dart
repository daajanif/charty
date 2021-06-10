import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:mighty_notes/model/SubscriptionModel.dart';
import 'package:mighty_notes/screens/AddSubscriptionReminderScreen.dart';
import 'package:mighty_notes/screens/NotificationScreen.dart';
import 'package:mighty_notes/utils/Constants.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class SubscriptionDetailScreen extends StatefulWidget {
  SubscriptionModel model;

  SubscriptionDetailScreen({this.model});

  @override
  SubscriptionDetailScreenState createState() => SubscriptionDetailScreenState();
}

class SubscriptionDetailScreenState extends State<SubscriptionDetailScreen> {
  BannerAd myBanner;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    myBanner = buildBannerAd()..load();
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      adUnitId: kReleaseMode ? mAdMobBannerId : BannerAd.testAdUnitId,
      size: AdSize.fullBanner,
      listener: AdListener(onAdLoaded: (ad) {
        //
      }),
      request: AdRequest(testDevices: testDevices),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text('Subscription Detail', style: primaryTextStyle()),
      ),
      body: Container(
        height: context.height(),
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: myBanner.size.height.toDouble()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: context.width(),
                    color: getColorFromHex(widget.model.color),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                icon: Icon(Icons.close),
                                color: getColorFromHex(widget.model.color).isDark() ? Colors.white.withOpacity(0.85) : Colors.black,
                                onPressed: () {
                                  finish(context);
                                }),
                            PopupMenuButton(
                              onSelected: (value) async {
                                if (value == 1) {
                                  SubscriptionModel res = await AddSubscriptionReminderScreen(subscriptionModel: widget.model).launch(context);
                                  setState(() {
                                    widget.model = res ?? widget.model;
                                  });
                                } else if (value == 2) {
                                  if (widget.model.firstPayDate == null && widget.model.dueDate.isBefore(DateTime.now())) {
                                    toastLong('Subscription expired. No notification available');
                                  } else {
                                    NotificationScreen(subscriptionModel: widget.model).launch(context);
                                  }
                                }
                              },
                              icon: Icon(Icons.more_vert_rounded, color: getColorFromHex(widget.model.color).isDark() ? Colors.white.withOpacity(0.85) : Colors.black),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit),
                                      8.width,
                                      Text('Edit', style: primaryTextStyle()),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_active_outlined),
                                      8.width,
                                      Text('Notification', style: primaryTextStyle()),
                                    ],
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        8.height,
                        Text(
                          widget.model.name.validate(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: primaryTextStyle(
                            size: 24,
                            color: getColorFromHex(widget.model.color).isDark() ? Colors.white.withOpacity(0.85) : Colors.black,
                          ),
                        ),
                        4.height,
                        widget.model.description.isNotEmpty
                            ? Text(
                                widget.model.description.validate(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: primaryTextStyle(
                                  size: 16,
                                  color: getColorFromHex(widget.model.color).isDark() ? Colors.white.withOpacity(0.85) : Colors.black,
                                ),
                              )
                            : SizedBox(),
                        4.height,
                        Text(
                          '₹ ${widget.model.amount.validate()}',
                          style: boldTextStyle(
                            size: 32,
                            color: getColorFromHex(widget.model.color).isDark() ? Colors.white.withOpacity(0.85) : Colors.black,
                          ),
                        ),
                      ],
                    ).paddingBottom(32),
                  ).cornerRadiusWithClipRRect(defaultRadius),
                  16.height,
                  widget.model.duration != null
                      ? Column(
                          children: [
                            Text('Billing Period', style: primaryTextStyle()),
                            2.height,
                            Text('every ${widget.model.duration.validate()}  ${widget.model.durationUnit.validate()}', style: secondaryTextStyle()),
                          ],
                        )
                      : SizedBox(),
                  widget.model.duration != null ? Divider(thickness: 1) : SizedBox(),
                  8.height,
                  widget.model.firstPayDate != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Next Payment', style: primaryTextStyle()),
                            2.height,
                            Text(DateFormat('yyyy-MM-dd').format(widget.model.nextPayDate).toString().validate(), style: secondaryTextStyle()),
                            Divider(thickness: 1),
                          ],
                        )
                      : SizedBox(),
                  8.height,
                  Text(widget.model.firstPayDate != null ? 'First payment' : 'Expiry Date', style: primaryTextStyle()),
                  2.height,
                  widget.model.firstPayDate != null
                      ? Text(DateFormat('yyyy-MM-dd').format(widget.model.firstPayDate).toString().validate(), style: secondaryTextStyle())
                      : Text(DateFormat('yyyy-MM-dd').format(widget.model.dueDate).toString().validate(), style: secondaryTextStyle()),
                  Divider(thickness: 1),
                  8.height,
                  Text('Payment method', style: primaryTextStyle()),
                  2.height,
                  widget.model.paymentMethod.isNotEmpty ? Text(widget.model.paymentMethod.validate(), style: secondaryTextStyle()) : Text('No payment method', style: secondaryTextStyle()),
                  Divider(thickness: 1),
                  Text('Notifications', style: primaryTextStyle()),
                  widget.model.notificationId != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${DateFormat('yyyy-MM-dd HH:mm a').format(widget.model.notificationDate)}', style: secondaryTextStyle()),
                            Text('₹ ${widget.model.amount}', style: secondaryTextStyle()),
                          ],
                        )
                      : Text('No notification', style: secondaryTextStyle()),
                ],
              ).paddingOnly(left: 16, right: 16, top: 16),
            ),
            if (myBanner != null)
              Positioned(
                child: AdWidget(ad: myBanner),
                bottom: 0,
                height: AdSize.banner.height.toDouble(),
                width: context.width(),
              ),
          ],
        ),
      ),
    );
  }
}
