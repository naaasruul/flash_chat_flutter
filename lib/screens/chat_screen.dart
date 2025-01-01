import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late User loggedInUser;

  String messageText = '';

  void getCurrentUser() async {
    final user = await _auth.currentUser;

    if (user != null) {
      loggedInUser = user;
      print(loggedInUser.email);
    }
  }

  //
  // void getMessages() async{
  //   final messages = await _firestore.collection('messages').get();
  //   for(var message in messages.docs){
  //     print(message.data());
  //   }
  //
  // }

  void messagesStream() async {
    //
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data());
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                messagesStream();
                //Implement logout functionality
                // getMessages();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(backgroundColor: Colors.lightBlueAccent,),
                    );
                  }

                  final messages = snapshot.data?.docs;
                  List<Text> messageWidgets = [];

                  for (var message in messages!) {
                    final messageText =
                    (message.data() as Map<String, dynamic>?)?['text'];
                    final messageSender =
                    (message.data() as Map<String, dynamic>?)?['sender'];

                    final messageWidget =
                    Text('$messageText from $messageSender',style: TextStyle(color: Colors.white),);
                    messageWidgets.add(messageWidget);
                  }

                  return Column(
                    children: messageWidgets,
                  );
                }),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Implement send functionality.
                      _firestore.collection('messages').add(
                          {'text': messageText, 'sender': loggedInUser.email});
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
