import 'package:flutter/material.dart';

class LoginPhone extends StatelessWidget {
  final vm;
  final TextEditingController loginController;
  final TextEditingController loginControllerMoarref;
  const LoginPhone({Key key, this.vm, @required this.loginController, @required this.loginControllerMoarref}) : super(key: key);

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
                child: Text(" تلفن : "),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: loginController,
                  maxLength: 11,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: '09123456789',
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(" کد معرف : "),
              ),
              Expanded(
                flex: 8,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: loginControllerMoarref,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: '1234...',
                    counterText: '',
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
