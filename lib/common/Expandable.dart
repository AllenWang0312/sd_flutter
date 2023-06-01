import 'package:flutter/material.dart';
const TAG = "Expandable";
class Expandable extends StatefulWidget{
  Widget title;
  Widget more;
  bool expand = false;
  Expandable(this.expand, this.title, this.more);

  @override
  State<Expandable> createState() => _ExpandableState(expand);
}

class _ExpandableState extends State<Expandable> {

  bool expand = false;

  _ExpandableState(this.expand);

  @override
  Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Row(
         children: [
           ExpandIcon(
               isExpanded: expand,
               onPressed: (expand){
                 setState(() {
                   this.expand = !expand;
                 });
           }),
           widget.title,
         ],
       ),
       Offstage(
         offstage: !expand,
         child: widget.more,
       )
     ],
   );
  }
}