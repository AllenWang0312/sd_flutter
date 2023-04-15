import 'package:flutter/material.dart';
import 'package:sd/common/third_util.dart';
import 'package:sd/sd/config.dart';

class MineWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  if (await checkStoragePermission()) {
                    Navigator.pushNamed(context, ROUTE_SETTING);
                  }

                  // HistoryWidget(dbController),
                }),
          ],
        ),
        Expanded(child: Container())
      ],
    );
  }
}
