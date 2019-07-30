import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import 'oopt_bloc.dart';

import '../../../storage/repository.dart';

class OoptPage extends StatefulWidget {
  final int id;
  
  OoptPage(this.id);

  @override
  OoptPageState createState() => OoptPageState();
}

class OoptPageState extends State<OoptPage> {

  final bloc = OoptPageBloc();

  final repository = Repository();

  //WebViewController controller;

  @override
  void initState() {
    super.initState(); 

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Информация')),
      body: Container(
        padding: EdgeInsets.all(0),
        child: InAppWebView(
          initialFile: repository.getOotpLink(widget.id),
          initialOptions: {
            'textZoom': 100,
            'useWideViewPort': false
          },
          onLoadStart: (controller, link) {
            try {
              final path = link.split('/').sublist(5).join('/');
              if (path != repository.getOotpLink(widget.id)) {
                controller.stopLoading();
                controller.loadFile(repository.getOotpLink(widget.id));
              }
            } catch (ex) {
              controller.stopLoading();
              controller.loadFile(repository.getOotpLink(widget.id));
            }
          },
        )
      )
    );
  }
}