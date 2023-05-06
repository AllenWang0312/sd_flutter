// import 'package:flutter/material.dart';
// import 'package:sd/sd/const/config.dart';
//
// class StatefulAppBar extends StatelessWidget{
//
//   StatefulAppBar();
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       leading: leading==null?null:IconButton(onPressed: leadingCallback,icon: Icon(leading),),
//       centerTitle: true,
//       title: title==null? null:Text(title!),
//       actions: actions==null?null:actions!.keys
//         .map((e){
//           if(e is IconData){
//             return IconButton(onPressed: actions![e], icon: Icon(e));
//           }else if(e is Widget){
//             return InkWell(onTap: actions![e],child: e,);
//           }
//           return Container();
//       })
//         .toList(),
//     );
//   }
//
//
//   void markNeedRebuild() {
//     setState(() {});
//   }
// }
