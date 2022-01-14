import 'package:flutter/material.dart';

class SeenStatus extends StatefulWidget {
  final String? avatar;
  final double initOffset;
  const SeenStatus({Key? key, this.avatar, required this.initOffset}) : super(key: key);

  @override
  _SeenStatusState createState() => _SeenStatusState();
}

class _SeenStatusState extends State<SeenStatus>
    with SingleTickerProviderStateMixin {
  late final Animation<Offset> _tweenAnimation;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200));
    _tweenAnimation =
        Tween<Offset>(begin: Offset(0, -(widget.initOffset/12)), end: const Offset(0, 0))
            .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _tweenAnimation,
      child: CircleAvatar(
        backgroundImage: (widget.avatar == null
            ? const AssetImage("assets/images/person.png")
            : NetworkImage(widget.avatar!)) as ImageProvider,
        radius: 6,
      ),
    );
  }
}
