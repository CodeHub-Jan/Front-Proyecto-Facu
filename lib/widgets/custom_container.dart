import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatefulWidget {
  EdgeInsetsGeometry? padding;
  Widget child;
  double containerWith, containerHeight;
Color? color;
  CustomContainer(
      {super.key, required this.child, required this.containerWith, required this.containerHeight
      ,this.padding, this.color
      });

  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(

      padding: widget.padding,
      width: widget.containerWith,
      height: widget.containerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: widget.color ?? Colors.white,
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, spreadRadius: 2, blurRadius: 4),
        ],
      ),
      child: widget.child,
    );
  }
}
