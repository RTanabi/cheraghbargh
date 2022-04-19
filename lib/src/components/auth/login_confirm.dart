import 'package:flutter/material.dart';

class LoginConfirm extends StatelessWidget {
  final vm;
  final confirmController;
  const LoginConfirm({Key key, this.vm, this.confirmController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(" کد تایید : "),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  controller: confirmController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    labelText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
