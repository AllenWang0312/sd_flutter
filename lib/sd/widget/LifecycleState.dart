

import 'package:flutter/cupertino.dart';

abstract class LifecycleState<T extends StatefulWidget> extends State<T> with WidgetsBindingObserver{

 @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

 }

 @override
 void dispose() {
   WidgetsBinding.instance.removeObserver(this);
   super.dispose();
 }

}