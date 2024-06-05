import 'package:flutter/material.dart';

import '../../../bean/db/Translate.dart';
import '../../../http_service.dart';

const TAG = "DragPromptWidget";

class SDDragPromptWidget extends StatefulWidget {
  List<Translate> split;

  SDDragPromptWidget(this.split);

  DragPromptState state =  DragPromptState();
  @override
  State<StatefulWidget> createState() =>state;

  void showTrans(bool bool) {
    state.showTranslate(bool);
  }
}

class DragPromptState extends State<SDDragPromptWidget> {

  bool showTrans = false;

  void showTranslate(bool bool) {
    setState(() {
      showTrans = bool;
    });
  }

@override
Widget build(BuildContext context) {
  return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: _dragableList());
}


List<Widget> _dragableList() {
  List<Widget> result = [];
  for (int i = 0; i < widget.split.length; i++) {
    Translate item = widget.split[i];
    result.add(RawChip(
        onDeleted: () {
          setState(() {
            widget.split.removeAt(i);
          });
        },
        label: DragTarget<Translate>(onWillAccept: (data) {
          logt(TAG, " $data");

          if (data == item || data == null) {
            return false;
          } else {
            return true;
          }
        }, onAccept: (data) {
          logt(TAG, " $data");
          setState(() {
            widget.split.remove(data);
            widget.split.insert(i, data);
          });
        }, builder: (context, candidate, rejected) {
          return Draggable(
            data: item,
            childWhenDragging:
            _childWrapper(Colors.lightGreen, Text(item.keyWords)),
            feedback: _childWrapper(
                Colors.redAccent,
                Text(
                  item.keyWords,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                )),
            child: Text(showTrans ? item.translate ?? "正在检索" : item.keyWords),
            onDragStarted: () {},
            onDragUpdate: (details) {},
            onDragEnd: (details) {
              // details.
            },
            onDraggableCanceled: (Velocity velocity, offset) {
              logt(TAG, "drag Canceled");
            },
            onDragCompleted: () {
              logt(TAG, "drag success");
            },
          );
        })));
  }
  return result;
}

@override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

  }

Widget _childWrapper(Color color, Widget child) {
  return Container(
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.all(Radius.circular(8))),
      child: child);
}}
