import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';

import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../storage/repository.dart';

class ContactsPage extends StatefulWidget {
  
  ContactsPage();

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> {

  @override
  void initState() {
    super.initState(); 
  }

  Widget buildHtml() {
    return Container(
      child: InAppWebView(
        initialFile: 'assets/data/contacts/index.html',
        initialOptions: {
          'textZoom': 100,
          'useWideViewPort': false
        },
        onLoadStart: (controller, link) {
          try {
            final path = link.split('/').sublist(5).join('/');
            if (path != 'assets/data/contacts/index.html') {
              controller.stopLoading();
              controller.loadFile('assets/data/contacts/index.html');
            }
          } catch (ex) {
            controller.stopLoading();
            controller.loadFile('assets/data/contacts/index.html');
          }
        },
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHtml();
  }
}