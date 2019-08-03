import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../fullscreen_images/fullscreen_images_page.dart';

import '../../dialogs/dialogs.dart';

import '../../resources/app_colors.dart';

import '../../../storage/repository.dart';

class ContactsPage extends StatefulWidget  {
  
  ContactsPage();

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage> with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState(); 
  }

  @override
  bool get wantKeepAlive => true;

  Widget buildListElem(String title, String child, {Function onTap}) {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15, top: 10),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
            ),
          ),
          Flexible(
            child: RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: '${title}: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w300
                    ),
                  ),
                  TextSpan(
                    text: child,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                      decoration: onTap != null ? TextDecoration.underline : TextDecoration.none
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTap
                  )
                ]
              )
            )
          )
        ]
      )
    );
  }

  Widget buildHtml() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child:  Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ExpansionTile(
              title: Container(
                child: Text('Дирекция особо охраняемых природных территорий Ленинградской области филиал Ленинградского областного государственного казенного учреждения "Управление лесами Ленинградской области"',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 14
                  ),
                ),
              ),
              children: <Widget>[ 
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Image(
                    width: width,
                    image: AssetImage('assets/data/contacts/images/logo_4.jpg'),
                  ),
                ),
                buildListElem('Адрес', 'г. Санкт-Петербург, ул. Торжковская, д. 4, офис 432, 197342',),
                buildListElem('Телефон', '+7(812)492-96-10', onTap: () {
                  launch('tel:+7(812)492-96-10');
                }),
                buildListElem('Email', 'oopt.lo@yandex.ru', onTap: () {
                  launch('mailto:oopt.lo@yandex.ru');
                }),
                buildListElem('Сайт', 'www.ooptlo.ru', onTap: () {
                  launch('http://ooptlo.ru');
                }),
                buildListElem('Директор филиала', 'Кухарский Павел Игоревич',),
                Padding(padding: EdgeInsets.only(bottom: 20))
              ]
            ),
            ExpansionTile(
              title: Container(
                child: Text('Ленинградское областное государственное казенное учреждение "Управление лесами Ленинградской области" (ЛОГКУ "Ленобллес")"',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 14
                  ),
                ),
              ),
              children: <Widget>[ 
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Image(
                    width: width,
                    image: AssetImage('assets/data/contacts/images/logku_logo.jpg'),
                  ),
                ),
                buildListElem('Адрес', 'г. Санкт-Петербург, ул. Белоостровская, д. 22, 197342',),
                buildListElem('Телефон/Факс', '+7(812)643-44-14', onTap: () {
                  launch('tel:+7(812)643-44-14');
                }),
                buildListElem('Email', 'logbules@gmail.com', onTap: () {
                  launch('mailto:logbules@gmail.com');
                }),
                buildListElem('И.о. директора', 'Новиков Михаил Алексеевич',),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
                  child: Text('Региональный пункт диспетчерского управления (РПДУ)',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16
                    ),
                  ),
                ),
                buildListElem('Телефон', '+7(812)492-96-06', onTap: () {
                  launch('tel:+7(812)492-96-06');
                }),
                buildListElem('Email', 'forestfire_logbu@mail.ru', onTap: () {
                  launch('mailto:forestfire_logbu@gmail.com');
                }),
                Padding(padding: EdgeInsets.only(bottom: 20))
              ]
            ),
            ExpansionTile(
              title: Container(
                child: Text('Комитет по природным ресурсам Ленинградской области',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.55),
                    fontSize: 14
                  ),
                ),
              ),
              children: <Widget>[ 
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
                  child: Image(
                    width: width,
                    image: AssetImage('assets/data/contacts/images/logo_5.png'),
                  ),
                ),
                buildListElem('Адрес', 'г. Санкт-Петербург, улица Торжковская, дом 4, 197342',),
                buildListElem('Телефон/Факс', '+7(812)496-56-36', onTap: () {
                  launch('tel:+7(812)492-56-36');
                }),
                buildListElem('Email', 'lpc@lenreg.ru', onTap: () {
                  launch('mailto:lpc@lenreg.ru');
                }),
                buildListElem('Председатель комитета', 'Андреев Евгений Львович',),
                Container(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
                  child: Text('Отдел особо охраняемых природных территорий',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16
                    ),
                  ),
                ),
                buildListElem('Телефон', '+7(812)492-62-16', onTap: () {
                  launch('tel:+7(812)492-62-16');
                }),
                buildListElem('Начальник отдела', 'Стулов Федор Николаевич',),
                Padding(padding: EdgeInsets.only(bottom: 20))
              ]
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 7),
              child: Text('Телефон "Зеленой линии" (принимаются жалобы на нарушения режима особой охраны ООПТ):',
                style: TextStyle(
                  color: Colors.green
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launch('tel:+7(812)492-99-30');
              },
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Text('+7(812)492-99-30',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    decoration: TextDecoration.underline
                  ),
                ),
              )
            ),
            Container(
              padding: EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 7),
              child: Text('В случае обнаружения огня в лесу необходимо немедленно позвонить по телефону:',
                style: TextStyle(
                  color: Colors.red
                ),
              ),
            ),
            InkWell(
              onTap: () {
                launch('tel:+7(812)908-91-11');
              },
              child: Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Text('+7(812)908-91-11',
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.75),
                    decoration: TextDecoration.underline
                  ),
                ),
              )
            )
          ],
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildHtml();
  }
}