import 'package:flutter/material.dart';

import '../commons/app_color.dart';


class CustomText extends StatelessWidget {
  final String title;
   bool? isPasswordText=false;
   TextEditingController? controller;
   bool? readOnly;
   CustomText({Key? key, required  this.title,  this.controller,this.isPasswordText, this.readOnly}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly == null ? false : readOnly!,
        obscureText: (isPasswordText ??  false),
        enableSuggestions: !(isPasswordText ??  false),
        autocorrect: !(isPasswordText ??  false),
      onChanged: (a){

      },
      controller: controller,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(
            color: Colors.black
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.darkBlue),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.blue),
        ),
      ),
    );
  }
}
