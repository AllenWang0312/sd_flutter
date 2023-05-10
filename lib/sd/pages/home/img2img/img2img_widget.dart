import 'package:flutter/material.dart';
import 'package:sd/sd/pages/home/img2img/prompt_style_picker.dart';
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
  @override
  Widget build(BuildContext context) {
   return Column();
  }
}
