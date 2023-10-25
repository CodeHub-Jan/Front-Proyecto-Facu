import 'package:flutter/material.dart';

import '../commons/app_color.dart';


class LoadingWidget extends StatelessWidget {
  const LoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: 50.0,
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child:  CircularProgressIndicator(
          color: AppColor.blue,
          strokeWidth: 6,
          backgroundColor: AppColor.darkBlue,
        ),
      ),
    );
  }
}
