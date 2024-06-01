

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sd/sd/history/history_widget.dart';

class ChatPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return ChatPageState();
  }

}

class ChatPageState extends State<ChatPage>{
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: HistoryWidget()),
        CupertinoTextField()
      ],
    );
  }

}