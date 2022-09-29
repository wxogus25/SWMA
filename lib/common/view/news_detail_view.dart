import 'package:flutter/material.dart';

import '../layout/default_layout.dart';

class NewsDetailView extends StatelessWidget {
  const NewsDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(isExtraPage: true, child: Text("test"), pageName: "뉴스 상세",);
  }
}
