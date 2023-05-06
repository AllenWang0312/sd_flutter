import 'package:flutter/material.dart';

class WebDrawer extends StatefulWidget {
  // bool vivid;
  // double? min;
  // double? max;

  Widget Function(bool expand) getChild;

  WebDrawer(this.getChild,{super.key,
    // this.vivid = false, this.min = 60, this.max = 60
  });

  @override
  State<StatefulWidget> createState() => _WebDrawerState();
}

class _WebDrawerState extends State<WebDrawer>
    // with SingleTickerProviderStateMixin
{
  // Animation<double>? animation;
  // AnimationController? controller;

  @override
  void initState() {
    super.initState();
    // if (widget.vivid) {
    //   controller = AnimationController(
    //       duration: const Duration(microseconds: 300), vsync: this);
    //   animation = Tween<double>(begin: widget.min, end: widget.max)
    //       .animate(controller!)
    //     ..addListener(() {});
    //   controller!.forward();
    // }
  }

  bool expand = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
        duration: const Duration(microseconds: 300),
        width: expand ? 300 : 60,
        child: MouseRegion(
            onEnter: (_) {
              setState(() {
                expand = true;
              });
            },
            onExit: (_) {
              setState(() {
                expand = false;
              });
            },
            child: widget.getChild(expand)));
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }
}
