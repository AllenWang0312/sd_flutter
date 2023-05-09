import 'package:flutter/material.dart';
import 'package:sd/common/util/string_util.dart';
import 'package:sd/sd/bean/db/Translate.dart';
import 'package:sd/sd/db_controler.dart';

import '../http_service.dart';

const TAG = "AutoCompletePage";

class AutoCompletePage extends StatelessWidget {
  String? title = '';
  String? prompt = '';

  AutoCompletePage(this.title, this.prompt, {super.key}) {
    promptController = TextEditingController(text: prompt ?? "");
  }

  late TextEditingController promptController;

  late TextEditingController enController;
  late TextEditingController cnController;

  @override
  Widget build(BuildContext context) {
    // promptController.addListener(() {
    //
    // });
    enController = TextEditingController();
    cnController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text(title ?? ""),
      ),
      body: Column(
        children: [
          TextFormField(
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.multiline,
            controller: promptController,
            minLines: 4,
            maxLines: 8,
          ),
          Table(
            // columnWidths:  const {
            //   0:FixedColumnWidth(double.infinity),
            //   // 1:FixedColumnWidth(50),
            //   2:FixedColumnWidth(48),
            //   3:FixedColumnWidth(double.infinity),
            // },
            children: [
              const TableRow(children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'English',
                    textAlign: TextAlign.center,
                  ),
                ),
                // Icon(Icons.translate_sharp),
                Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('中文', textAlign: TextAlign.center)),
              ]),
              TableRow(children: [
                _enAutoComplate(),
                _cnAutoComplate(),
              ])
            ],
          )
        ],
      ),
    );
  }

  final TextStyle lightTextStyle = const TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );

  InlineSpan formSpan(String all, String text) {
    List<TextSpan> spans = [];
    List<String> parts = all.split(text);
    logt(TAG, "parts" + parts.toString());
    if (parts.length > 1) {
      for (int i = 0; i < parts.length; i++) {
        if (i == parts.length - 1) {
          spans.add(TextSpan(text: text, style: lightTextStyle));
        }
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(text: parts[i]));
        }

      }
    } else {
      spans.add(TextSpan(text: all));
    }
    return TextSpan(children: spans);
  }

  List<Translate> _options(List? query) {
    logt(TAG, query.toString());
    if (null != query && query.isNotEmpty) {
      return query.map((e) => Translate.fromJson(e)).toList();
    } else {
      return [Translate('暂无搜索结果')];
    }
  }

  Widget _cnAutoComplate() {
    return Autocomplete<Translate>(onSelected: (value) {
      logt(TAG, 'item selected $value');
      // cnController.clear();
      promptController.text =
          '${appendCommaIfNotExist(promptController.text)}${value.keyWords},';
    },
        //     optionsViewBuilder: (context, onSelected, options) {
        //   return Column(
        //     children: options.map((e) => Text(e.keyWords)).toList(),
        //   );
        // },

        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
      cnController = textEditingController;
      return Stack(
        children:[
          TextFormField(
            controller: textEditingController,
            focusNode: focusNode,

            onFieldSubmitted: (value) {
              onFieldSubmitted();
            },
            // onFieldSubmitted: (String value) {},
          ),
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: Offstage(
              offstage: textEditingController.text.isEmpty,
              child: IconButton(icon: Icon(Icons.delete),onPressed: (){
                  textEditingController.clear();
            },),
            ),
          )
        ] ,
      );
    }, optionsViewBuilder: (context, onSelected, options) {
      return Material(
        child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (_, index) {
              Translate item = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(item),
                child: ListTile(
                  title: Text(item.keyWords),
                  subtitle:
                      Text.rich(formSpan(item.translate, cnController.text)),
                ),
              );
            }),
      );
    }, optionsBuilder: (editting) async {
      List? query = await DBController.instance
          .queryTranslate(Translate.Columns[3], editting.text, 0, 20);
      return _options(query);
    });
  }

  Widget _enAutoComplate() {
    return Autocomplete<Translate>(onSelected: (value) {
      logt(TAG, 'item selected $value');
      enController.clear();
      promptController.text =
          "${appendCommaIfNotExist(promptController.text)}${value.keyWords},";
    },
        //     optionsViewBuilder: (context, onSelected, options) {
        //   return Column(
        //     children: options.map((e) => Text(e.keyWords)).toList(),
        //   );
        // },

        fieldViewBuilder:
            (context, textEditingController, focusNode, onFieldSubmitted) {
      enController = textEditingController;
      return TextFormField(
        controller: textEditingController,
        focusNode: focusNode,
        onFieldSubmitted: (value) {
          onFieldSubmitted();
        },
        // onFieldSubmitted: (String value) {},
      );
    }, optionsViewBuilder: (context, onSelected, options) {
      return Material(
        child: ListView.builder(
            itemCount: options.length,
            itemBuilder: (_, index) {
              Translate item = options.elementAt(index);
              return InkWell(
                onTap: () => onSelected(item),
                child: ListTile(
                  title: Text.rich(formSpan(item.keyWords, enController.text)),
                  subtitle: Text(item.translate),
                ),
              );
            }),
      );
    }, optionsBuilder: (editting) async {
      List? query = await DBController.instance
          .queryTranslate(Translate.Columns[0], editting.text, 0, 20);
      return _options(query);
    });
  }
}
