

import 'package:flutter/cupertino.dart';

class RestartableWidget extends StatefulWidget{

  final Widget child;

  static void restartApp(BuildContext context){
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  RestartableWidget(this.child);

  @override
  State<StatefulWidget> createState()=> _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartableWidget>{
  Key key = UniqueKey();
  void restartApp(){
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
   return KeyedSubtree(
       key:key,
       child: widget.child);
  }

}