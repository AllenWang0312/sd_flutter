import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sd/common/util/ui_util.dart';
import 'package:sd/sd/const/config.dart';
import 'package:sd/sd/const/sp_key.dart';
import 'package:sd/sd/http_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TAG = "IPConfigWidget";

class IPConfigWidget extends StatefulWidget {
  bool? share;

  IPConfigWidget(this.share);

  @override
  State<StatefulWidget> createState() => IPConfigState();
}

class IPConfigState extends State<IPConfigWidget> {
  late SharedPreferences sp;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    sp = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController shareController =
        TextEditingController(text: sdPublicDomain);
    TextEditingController hostController = TextEditingController(text: sdHost);

    return Row(
      children: [
        Column(
          children: [
            Radio<bool>(
                value: true,
                toggleable: true,
                groupValue: widget.share,
                onChanged: _switchShare),
            Radio<bool>(
                value: false,
                toggleable: true,
                groupValue: widget.share,
                onChanged: _switchShare),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              _netWorkSetting(shareController, true),
              _netWorkSetting(hostController, false),
            ],
          ),
        )
      ],
    );
  }

  Widget _netWorkSetting(TextEditingController hostController, bool uiShare) {
    String? target = uiShare ? sdPublicDomain : sdHost;
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Text("  ${uiShare ? 'https' : 'http'}://"),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: TextField(
                decoration: const InputDecoration(border: InputBorder.none),
                controller: hostController,
              ),
            ),
          ),
          Text(uiShare ? ".gradio.live" : ":$SD_PORT"),
          TextButton(
              onPressed: () async {
                sp = await SharedPreferences.getInstance();
                if (hostController.text != target) {
                  if (uiShare) {
                    sp.setString(SP_SHARE_HOST, hostController.text);
                    sp.setBool(SP_SHARE, true);
                    sdPublicDomain = hostController.text;
                  } else {
                    sp.setString(SP_HOST, hostController.text);
                    sp.setBool(SP_SHARE, false);
                    sdHost = hostController.text;
                  }
                  showRestartDialog(context);
                } else {
                  Fluttertoast.showToast(
                      msg: AppLocalizations.of(context).networkNotChanged,
                      gravity: ToastGravity.CENTER);
                }
              },
              child: Text(AppLocalizations.of(context).save))
        ],
      ),
    );
  }

  void _switchShare(bool? newValue) {
    if (null != newValue) {
      logt(TAG, newValue.toString() ?? 'null');
      setState(() {
        widget.share = newValue;
      });
      sdShare = newValue;
      sp.setBool(SP_SHARE, newValue);
    }
  }
}
