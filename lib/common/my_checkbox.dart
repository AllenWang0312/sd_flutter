import 'package:flutter/material.dart';

class MyCheckBox extends StatelessWidget {

  bool checked;
  Function(bool?) onChanged;
  String title;


  MyCheckBox(this.checked, this.onChanged, this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
            value: checked,
            onChanged: onChanged),
        Text(title),
      ],
    );
  }
}
