import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sd/sd/pages/home/img2img/prompt_style_picker.dart';
import 'package:sd/sd/provider/AIPainterModel.dart';
import 'package:sd/sd/provider/AppBarProvider.dart';

class IMG2IMGWidget extends StatefulWidget {
  IMG2IMGWidget({super.key});

  @override
  State<IMG2IMGWidget> createState() => _IMG2IMGWidgetState();
}

class _IMG2IMGWidgetState extends State<IMG2IMGWidget> {
  final PromptStylePicker promptStylePicker = PromptStylePicker();

  Map<IconData, Function()> actions = {};

  AppBarProvider? appBar;

  // const RollWidget();
  late AIPainterModel provider;
  @override
  Widget build(BuildContext context) {
    provider = Provider.of<AIPainterModel>(context,listen: false);
   return  SingleChildScrollView(
       child:
       // provider.styleFrom == 3 ?
       provider.optional.generate(provider)
     // : generateStyles(provider.publicStyles)
   );;
  }
}
