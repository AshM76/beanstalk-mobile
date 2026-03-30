import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_dispensary_model.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_clinician_model.dart';

import '../../services/chatting/chat_service.dart';
import '../../ui/app_skin.dart';
import '../../utils/loading.dart';

class ChatListPage extends StatefulWidget {
  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> with TickerProviderStateMixin {
  final chatServices = ChatServices();
  List<ChatDispensary> _chatDispensaryList = [];
  List<ChatClinician> _chatClinicianList = [];

  int _indexScreen = 0;

  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      loadChatDispensaryList(context);
    }();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(size.height * 0.066),
          child: AppBar(
            elevation: 0.0,
            automaticallyImplyLeading: false,
            backgroundColor: AppColor.background,
            flexibleSpace: SafeArea(
              child: FlexibleSpaceBar(
                title: Container(
                  child: Center(
                    child: Image.network(
                      AppLogos.iconImg,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColor.content,
                ),
                onPressed: () => Navigator.pushReplacementNamed(context, 'navigation')),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: AppColor.background,
            child: Column(
              children: [
                Container(
                  height: size.height * 0.05,
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Chats",
                      style: TextStyle(
                        fontSize: AppFontSizes.titleSize + (size.width * 0.01),
                        fontFamily: AppFont.primaryFont,
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                _initChatsListContent(context),
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
        ));
  }

  Widget _initChatsListContent(BuildContext context) {
    final size = MediaQuery.of(context).size;
    TabController _tabController = TabController(length: 2, initialIndex: _indexScreen, vsync: this);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.height * 0.02,
      ),
      child: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            height: kToolbarHeight - 8.0,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: TabBar(
              onTap: (index) {
                _indexScreen = index;
                if (index == 0) {
                  loadChatDispensaryList(context);
                } else {
                  loadChatClinicianList(context);
                }
              },
              controller: _tabController,
              indicator: BoxDecoration(borderRadius: BorderRadius.circular(10.0), color: AppColor.secondaryColor),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColor.background,
              unselectedLabelColor: AppColor.content,
              tabs: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_sharp),
                    SizedBox(width: 5.0),
                    Text(
                      "Dispensaries",
                      style: TextStyle(
                        fontSize: AppFontSizes.contentSize + 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.perm_contact_calendar_rounded),
                    SizedBox(width: 5.0),
                    Text(
                      "Clinicians",
                      style: TextStyle(
                        fontSize: AppFontSizes.contentSize + 1.0,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
              width: double.maxFinite,
              height: double.maxFinite,
              child: TabBarView(
                controller: _tabController,
                children: [
                  SingleChildScrollView(child: _initDispensaryChats(context)),
                  SingleChildScrollView(child: _initClinicianChats(context)),
                ],
              )),
        ],
      )),
    );
  }

  //DISPENSARY-CHATS
  Widget _initDispensaryChats(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      child: _chatDispensaryList.length > 0
          ? ListView.builder(
              itemCount: _chatDispensaryList.length, itemBuilder: (BuildContext context, int index) => buildChatDispensaryCard(context, index))
          : Container(
              color: AppColor.content.withOpacity(0.1),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Empty list!",
                        style: TextStyle(fontSize: AppFontSizes.subTitleSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        "You have no chats all this moment",
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize - 1.0,
                          color: AppColor.content.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildChatDispensaryCard(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 90.0,
      child: InkWell(
        child: Card(
          semanticContainer: true,
          elevation: 2,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[BoxShadow(color: AppColor.content, blurRadius: 2.0, offset: Offset(0.5, 0.5))],
              color: AppColor.background,
            ),
            child: Align(
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.2,
                    height: 55,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/dispensary.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(12.5)),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Container(
                      height: size.height * 0.07,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _chatDispensaryList[index].storeName!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.subTitleSize,
                              color: AppColor.content,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            _chatDispensaryList[index].lastMessage!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSmallSize,
                              color: AppColor.content,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -17.5, end: -15),
                        // padding: EdgeInsets.all(8),
                        badgeContent: Text(
                          _chatDispensaryList[index].unreads.toString(),
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.background),
                        ),
                        child: Icon(
                          Icons.message_rounded,
                          size: size.height * 0.030,
                          color: AppColor.secondaryColor,
                        ),
                        showBadge: _chatDispensaryList[index].unreads! > 0 ? true : false,
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        DateFormat.Hm().format(_chatDispensaryList[index].lastDate!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSmallSize,
                          color: AppColor.content,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.005),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          print(_chatDispensaryList[index]);
          Navigator.pushNamed(context, 'chat_private', arguments: _chatDispensaryList[index]);
        },
      ),
    );
  }

  //CLINICIAN-CHATS
  Widget _initClinicianChats(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.75,
      child: _chatClinicianList.length > 0
          ? ListView.builder(
              itemCount: _chatClinicianList.length, itemBuilder: (BuildContext context, int index) => buildChatClinicianCard(context, index))
          : Container(
              color: AppColor.background,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Empty list!",
                        style: TextStyle(fontSize: AppFontSizes.subTitleSize, color: AppColor.content, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        "You have no chats all this moment",
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSize - 1.0,
                          color: AppColor.content.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget buildChatClinicianCard(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: 90.0,
      child: InkWell(
        child: Card(
          semanticContainer: true,
          elevation: 2,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[BoxShadow(color: AppColor.content, blurRadius: 2.0, offset: Offset(0.5, 0.5))],
              color: AppColor.background,
            ),
            child: Align(
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.15,
                    height: size.width * 0.15,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/clinician.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(size.width * 0.15)),
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Container(
                      height: size.height * 0.07,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _chatClinicianList[index].clinicianName!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.subTitleSize,
                              color: AppColor.content,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Text(
                            _chatClinicianList[index].lastMessage!,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: AppFontSizes.contentSmallSize,
                              color: AppColor.content,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      badges.Badge(
                        position: badges.BadgePosition.topEnd(top: -17.5, end: -15),
                        // padding: EdgeInsets.all(8),
                        badgeContent: Text(
                          _chatClinicianList[index].unreads.toString(),
                          style: TextStyle(fontSize: AppFontSizes.contentSize, color: AppColor.background),
                        ),
                        child: Icon(
                          Icons.message_rounded,
                          size: size.height * 0.030,
                          color: AppColor.secondaryColor,
                        ),
                        showBadge: _chatClinicianList[index].unreads! > 0 ? true : false,
                      ),
                      SizedBox(height: size.height * 0.005),
                      Text(
                        DateFormat.Hm().format(_chatClinicianList[index].lastDate!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: AppFontSizes.contentSmallSize,
                          color: AppColor.content,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: size.height * 0.005),
                ],
              ),
            ),
          ),
        ),
        onTap: () {
          print(_chatClinicianList[index]);
          Navigator.pushNamed(context, 'chat_clinician_private', arguments: _chatClinicianList[index]);
        },
      ),
    );
  }

  //API-CONNECT
  loadChatDispensaryList(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await chatServices.loadChatDispensaryList();
    if (infoResponse['ok']) {
      setState(() {
        _chatDispensaryList = [];

        final chatsResult = infoResponse['chats'] ?? [];
        chatsResult.forEach((chat) {
          ChatDispensary tempChat = ChatDispensary.fromJson(chat);
          _chatDispensaryList.add(tempChat);
        });

        progressDialog.dismiss();
      });
    } else {
      _chatDispensaryList = [];
      progressDialog.dismiss();
    }
  }

  loadChatClinicianList(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    Map infoResponse = await chatServices.loadChatClinicianList();
    if (infoResponse['ok']) {
      setState(() {
        _chatClinicianList = [];

        final chatsResult = infoResponse['chats'] ?? [];
        chatsResult.forEach((chat) {
          ChatClinician tempChat = ChatClinician.fromJson(chat);
          _chatClinicianList.add(tempChat);
        });

        progressDialog.dismiss();
      });
    } else {
      _chatClinicianList = [];
      progressDialog.dismiss();
    }
  }
}
