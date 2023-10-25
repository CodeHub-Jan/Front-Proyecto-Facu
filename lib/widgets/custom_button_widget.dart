import 'package:flutter/material.dart';

import '../commons/app_color.dart';


class CustomButton extends StatelessWidget {
   CustomButton(
      {Key? key,  this.onClick, required this.title, required this.icon, required this.buttonWith})
      : super(key: key);
   VoidCallback?  onClick;
  final String title;
  final IconData icon;
  final double buttonWith;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: buttonWith,
      child: ElevatedButton.icon(onPressed: onClick,
          icon: Icon(icon, color: Colors.white,),
          label: Text(title, style: const TextStyle(color: Colors.white),),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.blue,
          )
      ),
    );
  }
}
