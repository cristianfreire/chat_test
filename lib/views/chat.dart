import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_test/shared/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;

  Chat({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CHAT',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ChatScreen(peerId: peerId, peerAvatar: peerAvatar),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;

  ChatScreen({Key key, @required this.peerId, @required this.peerAvatar})
      : super(key: key);

  @override
  _ChatScreenState createState() =>
      _ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState({Key key, @required this.peerId, @required this.peerAvatar});

  String peerId;
  String peerAvatar;
  String id;

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  String groupChatId;

  bool isShowSticker;

  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final TextEditingController textEditingController = TextEditingController();

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages

                buildListMessage(),
                // Sticker

                // Input content

                // buildInput
                buildInput(),
              ],
            )
          ],
        ),
        onWillPop: onBackPress);
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          //Button send image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          // Button send message
        ],
      ),
    );
  }

  Future getImage() async {}

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  void onSendMessage(String content, int type) {}

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(themeColor),
              ),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection('groupChatId')
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  );
                } else {
                  listMessage.addAll(snapshot.data.docs);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.docs[index]),
                    itemCount: snapshot.data.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildItem(int index, DocumentSnapshot document) {
    if (document.data()['idForm'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          document.data()['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document.data()['content'],
                    style: TextStyle(color: primaryColor),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: greyColor2,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document.data()['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                          ),
                        ),
                      ),
                    )
                  // Sticker
                  : Container()
        ],
      );
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }
}
