
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import '../provider/AppBarProvider.dart';

class WebHomeModel
    with ChangeNotifier, DiagnosticableTreeMixin
// extends AppBarProvider
{
 int layoutType = 0;
 double drawerWidth = 0;

  void updateLayoutType(int i) {
   if(layoutType!=i){
    layoutType = i;
    switch(i){
     case 0:
      drawerWidth = 0.0;
      break;
     case 1:
      drawerWidth = 60;
      break;
     case 2:
      drawerWidth = 300;
      break;
    }
    notifyListeners();
   }
  }
}
