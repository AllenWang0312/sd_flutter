import 'package:flutter/material.dart';
import 'package:sd/common/util/file_util.dart';
import 'package:sd/sd/bean/PromptStyle.dart';

class SDStyleConfigPage extends StatelessWidget {
  late String fileName;
  String styleAbsPath;
  int userAge;
  bool hasChange = false;

  SDStyleConfigPage(this.styleAbsPath, this.userAge) {
    fileName = styleAbsPath.substring(styleAbsPath.lastIndexOf('/') + 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: Text(fileName),
        ),
        body: FutureBuilder(
          future: loadPromptStyleFromCSVFile(styleAbsPath, userAge),
          builder: (context, snapshot) {
            List<TableRow> rows = [];
            rows.add(TableRow(
                children: PromptStyle.STYLE_HEAD.map((e) => Text(e)).toList()
            ));
            rows.addAll(snapshot.data!
                .map((e) => TableRow(children: [
              Text( e.group??""),
              Text(e.name),
              Text( (e.step ?? 0).toString()),
              Text( (e.limitAge ?? 0).toString()),
              Text( e.prompt??""),
              Text(e.negativePrompt??""),
            ]))
                .toList());
            if (snapshot.hasData) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    border: TableBorder.all(color: Colors.black12, width: 1),
                    children: rows,
                  ),
                ),
              );
            } else {
              return Text('数据加载中');
            }
          },
        ));
  }
}
