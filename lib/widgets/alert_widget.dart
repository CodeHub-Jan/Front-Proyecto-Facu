import 'package:flutter/material.dart';

class AlertWidget extends StatelessWidget {
  String? title;
  String? message;
   AlertWidget({Key? key, this.title, this.message}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:   Text(title ?? 'Titulo por Defecto'),
      content:  Text(
          message ?? 'Mensaje por Defecto'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true)
                .pop();
          },
          child:  const Text('OK'),
        ),
      ],
    );
  }
}
