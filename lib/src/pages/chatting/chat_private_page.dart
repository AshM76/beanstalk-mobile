import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:beanstalk_mobile/src/models/chatings/chat_dispensary_model.dart';
import 'package:beanstalk_mobile/src/models/chatings/chat_message_model.dart';
import 'package:beanstalk_mobile/src/preferences/user_preference.dart';

import '../../services/chatting/chat_service.dart';
import '../../ui/app_skin.dart';
import '../../utils/loading.dart';

class ChatPrivatePage extends StatefulWidget {
  @override
  _ChatPrivatePageState createState() => _ChatPrivatePageState();
}

class _ChatPrivatePageState extends State<ChatPrivatePage> {
  final _prefs = new UserPreference();
  final chatServices = ChatServices();
  ChatDispensary _chatHistory =
      ChatDispensary(id: '', dispensaryId: '', dispensaryName: '', storeId: '', storeName: '', lastMessage: '', messages: []);

  bool _chatConnected = false;

  late IO.Socket socket;
  double? height, width;
  TextEditingController? textController;
  ScrollController? scrollController;

  // LOCAL: 'http://192.168.0.???:3000' // STAGING: 'https://staging.beanstalk.app' // PROD: 'https://beanstalk.app'
  void connectAndListen() {
    socket = IO.io('https://staging.beanstalk.app', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      socket.on('message', (message) => {print(message)});
    });

    //Dispensary Connected in Chat
    socket.on('chatConnected', (message) => {_chatConnected = true, print(message)});

    //When an event recieved from server, data is added to the stream
    socket.on('receiveMessage', (message) => {this.setState(() => _chatHistory.messages!.add(ChatMessage.fromJson(message))), messageMarkRead()});

    socket.onDisconnect((_) => print('Chat disconnect'));
  }

  messageMarkRead() {
    Map<String, dynamic> message = {'projectId': _prefs.projectId, 'chatId': _chatHistory.id, 'readBy': _prefs.id};
    socket.emit('markReadDispensaryMessage', message);
  }

  @override
  void initState() {
    textController = TextEditingController();
    scrollController = ScrollController();
    connectAndListen();
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      _loadChatHistory(context);
    }();
    socket.connect();
  }

  @override
  void dispose() {
    super.dispose();
    socket.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
            onPressed: () => {
              socket.emit('leaveDispensaryChat'),
              // Navigator.of(context).pop(),
              Navigator.pushNamed(context, 'chat_list').then((_) => setState(() {})),
            },
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: size.height * 0.08,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              boxShadow: <BoxShadow>[BoxShadow(color: AppColor.content, blurRadius: 2.0, offset: Offset(0.5, 0.5))],
              color: AppColor.background,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Container(
                    width: size.width * 0.25,
                    height: size.height * 0.07,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/dispensary.jpg'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(15.0)),
                  ),
                  SizedBox(width: size.width * 0.025),
                  Container(
                    width: size.width * 0.6,
                    height: size.height * 0.07,
                    color: AppColor.background,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _chatHistory.storeName!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: AppFontSizes.subTitleSize,
                            color: AppColor.content,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.0025),
                        Text(
                          _chatHistory.dispensaryName!,
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: AppFontSizes.contentSize - 2.0,
                            color: AppColor.secondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: size.height * 0.005),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.circle,
                        //       size: 15,
                        //       color: AppColor.fifthColor,
                        //     ),
                        //     SizedBox(width: size.width * 0.005),
                        //     Text(
                        //       "Offline",
                        //       textAlign: TextAlign.left,
                        //       style: TextStyle(
                        //         fontSize: AppFontSizes.contentSmallSize,
                        //         color: AppColor.content,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            reverse: true,
            physics: BouncingScrollPhysics(),
            child: Container(
              color: AppColor.primaryColor.withOpacity(0.15),
              child: Column(
                children: [
                  SizedBox(height: height! * 0.015),
                  buildMessageList(),
                  buildInputArea(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSingleMessage(ChatMessage message) {
    return Container(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        margin: const EdgeInsets.only(bottom: 10.0, left: 25.0, right: 10.0),
        decoration: BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              message.content!,
              style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.5),
            Text(
              _loadDateTimeMessate(message.date!),
              style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10.0),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMessageReceived(ChatMessage message) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        margin: const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 25.0),
        decoration: BoxDecoration(
          color: AppColor.secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              message.content!,
              style: TextStyle(color: Colors.white, fontSize: 15.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 3.5),
            Text(
              _loadDateTimeMessate(message.date!),
              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10.0),
            )
          ],
        ),
      ),
    );
  }

  _loadDateTimeMessate(DateTime messageDateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final aDate = DateTime(messageDateTime.year, messageDateTime.month, messageDateTime.day);
    String dateMessage = '';
    if (aDate == today) {
      String formattedDate = DateFormat('kk:mm').format(messageDateTime);
      dateMessage = 'Today ' + formattedDate.toString();
    } else if (aDate == yesterday) {
      String formattedDate = DateFormat('kk:mm').format(messageDateTime);
      dateMessage = 'Yesterday ' + formattedDate.toString();
    } else {
      String formattedDate = DateFormat('EEE kk:mm, MM/d/yy').format(messageDateTime);
      dateMessage = formattedDate;
    }
    return dateMessage;
  }

  Widget buildMessageList() {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Container(
        height: (height! * 0.625) - MediaQuery.of(context).viewInsets.bottom,
        width: width,
        child: ListView.builder(
          controller: scrollController,
          itemCount: _chatHistory.messages!.isEmpty ? 0 : _chatHistory.messages!.length,
          itemBuilder: (BuildContext context, int index) {
            if (_chatHistory.messages![index].sentby == _prefs.id) {
              return buildSingleMessage(_chatHistory.messages![index]);
            } else {
              return buildMessageReceived(_chatHistory.messages![index]);
            }
          },
        ),
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: width! * 0.7,
      height: 40.0,
      padding: const EdgeInsets.all(5.0),
      margin: const EdgeInsets.only(left: 30.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message...',
        ),
        controller: textController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: AppColor.secondaryColor,
      onPressed: () {
        //Check if the textfield has text or not
        if (textController!.text.trim().isNotEmpty) {
          //Send the message as JSON data to send_message event
          final message = ChatMessage(
              id: 'mobile',
              date: DateTime.now().toUtc(),
              content: textController!.text,
              read: _chatConnected ? true : false,
              type: 'text',
              sentby: _prefs.id);

          final messageSend = {
            'projectId': _prefs.projectId,
            'chatId': _chatHistory.id,
            'message': message.toJson(),
          };

          socket.emit('sendDispensaryMessage', messageSend);
          //Add the message to the list
          this.setState(() => _chatHistory.messages!.add(message));
          if (_chatHistory.id!.isEmpty) {
            _createChat(context);
          }
          textController!.text = '';
          //Scrolldown the list to show the latest message
          scrollController!.animateTo(
            scrollController!.position.maxScrollExtent + (height! * 0.1),
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        } else {
          textController!.text = '';
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      // padding: EdgeInsets.only(bottom: height * 0.03),
      height: height! * 0.127,
      width: width,
      decoration: BoxDecoration(
        boxShadow: <BoxShadow>[BoxShadow(color: AppColor.content, blurRadius: 1.0, offset: Offset(-0.5, -0.5))],
        color: AppColor.background,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(40),
          topLeft: Radius.circular(40),
        ),
      ),
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  _loadChatHistory(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    _chatHistory = ModalRoute.of(context)?.settings.arguments as ChatDispensary? ?? '' as ChatDispensary;
    if (!_prefs.demoVersion) {
      try {
        Map infoResponse = await chatServices.loadChatDispensaryHistory(_chatHistory.id);
        if (infoResponse['ok']) {
          setState(() {
            _chatHistory.id = infoResponse['chat']['chat_id'];
            List<ChatMessage> messageListTemp = [];
            final messagesResult = infoResponse['chat']['chat_messages'] ?? [];
            messagesResult.forEach((message) {
              ChatMessage tempMessage = ChatMessage.fromJson(message);
              messageListTemp.add(tempMessage);
            });
            _chatHistory.messages = messageListTemp;
            socket.emit('joinDispensaryChat', _chatHistory.id);
            progressDialog.dismiss();
          });
        } else {
          progressDialog.dismiss();
          setState(() {});
          print("error load chat history");
        }
      } catch (e) {
        progressDialog.dismiss();
        _chatHistory.messages = [];
        setState(() {});
      }
    } else {
      progressDialog.dismiss();
      setState(() {});
    }
  }

  _createChat(BuildContext context) async {
    ProgressDialog progressDialog = ProgressDialog(context);
    progressDialog.show();
    if (!_prefs.demoVersion) {
      try {
        Map infoResponse = await chatServices.createChatDispensary(_chatHistory);
        if (infoResponse['ok']) {
          setState(() {
            List<ChatMessage> messageListTemp = [];
            final messagesResult = infoResponse['chat']['chat_messages'] ?? [];
            messagesResult.forEach((message) {
              ChatMessage tempMessage = ChatMessage.fromJson(message);
              messageListTemp.add(tempMessage);
            });
            _chatHistory.messages = messageListTemp;
            progressDialog.dismiss();
          });
        } else {
          progressDialog.dismiss();
          print("error start chat history");
        }
      } catch (e) {
        progressDialog.dismiss();
      }
    } else {
      progressDialog.dismiss();
    }
  }
}
