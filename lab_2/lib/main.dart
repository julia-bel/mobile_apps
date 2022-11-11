import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.red),
      home: EmailSender(),
    );
  }
}

class EmailSender extends StatefulWidget {
  const EmailSender({Key? key}) : super(key: key);

  @override
  _EmailSenderState createState() => _EmailSenderState();
}

class _EmailSenderState extends State<EmailSender> {
  bool _autoComplete = false;
  final _recipientController = TextEditingController();
  final _bodyController = TextEditingController();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _homeAddressController = TextEditingController();
  final _destAddressController = TextEditingController();

  Future<void> send() async {
    final Email email = Email(
      body: formatBodyText(),
      subject: _autoComplete
          ? _homeAddressController.text
          : _destAddressController.text,
      recipients: [_recipientController.text],
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email);
      platformResponse = 'Successfully sent';
    } catch (error) {
      log(error.toString());
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(platformResponse),
      ),
    );
  }

  String formatBodyText() {
    return '${_bodyController.text}\n\n${_nameController.text} '
        '${_lastnameController.text}\n${_numberController.text}\n'
        '${_homeAddressController.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Mail sender'),
        actions: <Widget>[
          IconButton(
            onPressed: send,
            icon: Icon(Icons.send),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 400,
            maxHeight: 1000,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Recipient',
                  ),
                ),
              ),
              AutofillGroup(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        autofillHints: const <String>[AutofillHints.givenName],
                        controller: _nameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Name',
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        autofillHints: const <String>[AutofillHints.familyName],
                        controller: _lastnameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Lastname',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  autofillHints: const <String>[AutofillHints.telephoneNumber],
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone number',
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.postalAddress],
                  controller: _homeAddressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Home address',
                  ),
                ),
              ),
              CheckboxListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0.0, horizontal: 8.0),
                title: Text('Destination address is home'),
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      _autoComplete = value;
                    });
                  }
                },
                value: _autoComplete,
              ),
              if (!_autoComplete)
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    autofillHints: const <String>[AutofillHints.postalAddress],
                    controller: _destAddressController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Destination address',
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _bodyController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                        labelText: 'Body', border: OutlineInputBorder()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
