import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:samba_browser/samba_browser.dart';

class SMBBrowser extends StatefulWidget {

  String shareUrl;
  String domain;
  String userName;
  String password;

  SMBBrowser(this.shareUrl, this.domain, this.userName, this.password);

  @override
  State<SMBBrowser> createState() => _SMBBrowserState();
}

class _SMBBrowserState extends State<SMBBrowser> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          onChanged: (text) => widget.shareUrl = text,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'SAMBA share URL',
          ),
        ),

        TextFormField(
          onChanged: (text) => widget.domain = text,
          decoration: const InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Domain',
          ),
        ),

        Row(
          children: [
            Flexible(
              child: TextFormField(
                onChanged: (text) => widget.userName = text,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Username',
                ),
              ),
            ),
            const SizedBox(width: 15.0),
            Flexible(
              child: TextFormField(
                onChanged: (text) => widget.password = text,
                obscureText: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
          ],
        ),

        TextButton(
            onPressed: () =>
                setState(() {
                  var shareFuture =;
                }),
            child: const Text("List available shares")
        ),

        const SizedBox(height: 30.0),

        FutureBuilder(future: SambaBrowser.getShareList(
            widget.shareUrl, widget.domain, widget.userName, widget.password),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Column(
                    children: [
                      const Text('An error has occurred.'),
                      Text(snapshot.error.toString())
                    ]);
              }
              if (!snapshot.hasData) return const CircularProgressIndicator();
              List<String> shares = (snapshot.data as List).cast<String>();
              return Column(children: shares.map((e) => Text(e)).toList());
            })

      ],
    );
  }
}