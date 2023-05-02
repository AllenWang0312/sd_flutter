export 'android.dart'
  if(dart.library.ios) 'ios.dart';


String syncPath = '';
String asyncPath = '';

String getCollectionsPath() => "$asyncPath/Collections";

String getWorkspacesPath() => "$asyncPath/Workspace";

String getStylesPath() => "$syncPath/Styles";