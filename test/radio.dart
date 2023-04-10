
import 'package:flutter/material.dart';

main(){
  runApp(FMRadioVC());

}



class FMRadioVC extends StatefulWidget{
  @override
  FMRadioState createState() => FMRadioState();
}

class FMRadioState extends State <FMRadioVC>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("CheckBox"),
      ),
      body: Center(
        child: _radioRow(),
      ),
    );
  }

  Row _radioRow(){
    return Row(
      children: [
        _colorfulCheckBox(1),
        _colorfulCheckBox(2),
        _colorfulCheckBox(3),
        _colorfulCheckBox(4),
        _colorfulCheckBox(5),
        _colorfulCheckBox(6),
      ],
    );
  }

  int groupValue = 1;

  Radio _colorfulCheckBox(index){
    return Radio(
      value: index,
      groupValue: groupValue,
      onChanged: (value){
        print(value);
        groupValue = index;

        setState(() {

        });
      },
    );
  }
}