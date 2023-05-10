
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/common/util/file_util.dart';


class StyleConfigPage extends StatelessWidget{

  late String fileName;
  String styleAbsPath;
int userAge;
  bool hasChange = false;

  StyleConfigPage(this.styleAbsPath,this.userAge){
    fileName = styleAbsPath.substring(styleAbsPath.lastIndexOf('/')+1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(fileName),
      ),
      body: FutureBuilder(
        future: loadPromptStyleFromCSVFile(styleAbsPath,userAge),
        builder: (context,snapshot){
          if(snapshot.hasData){
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0:FixedColumnWidth(80),
                    // 1:FixedColumnWidth(50),
                    2:FixedColumnWidth(200),
                    3:FixedColumnWidth(200),
                  },
                  border: TableBorder.all(color: Colors.black12, width: 1),
                  children: snapshot.data!.map((e) => TableRow(
                    children: [
                      TableCell(child: InkWell(onTap:(){
                        Fluttertoast.showToast(msg: e.name,gravity: ToastGravity.CENTER);
                      },child: TextFormField(initialValue:e.name))),
                      // TableCell(child: TextFormField(
                      //     initialValue:e.type??'null')),
                      TableCell(child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          initialValue:e.prompt?.trim())),
                      TableCell(
                          child: TextFormField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              initialValue:e.negativePrompt?.trim())),
                    ]
                  )).toList(),
                ),
              ),
            );
          }else{
            return Text('数据加载中');
          }
        },
      )
    );
  }



}