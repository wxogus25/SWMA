import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:tot/common/const/colors.dart';
import 'package:tot/common/const/padding.dart';
import 'package:tot/common/data/AppController.dart';
import 'package:tot/common/view/news_detail_view.dart';
import '../layout/default_layout.dart';

class NotifyView extends StatefulWidget {
  const NotifyView({Key? key}) : super(key: key);

  @override
  State<NotifyView> createState() => _NotifyViewState();
}

class _NotifyViewState extends State<NotifyView> {
  final AppController c = Get.put(AppController());
  bool deleteSign = false;
  List<Map<String, dynamic>>? notifyList;
  List<Map<String, dynamic>> test = [
    {
      "id": 123451,
      "title": "내년 가계 이자부담 132만원 는다",
      "time": "2022-11-18T18:21:03",
    },
    {
      "id": 41341,
      "title": "달러도 맛보고 주식도 맛보고 '자산 코스요리' 골고루 드세요",
      "time": "2022-11-18T16:05:39",
    },
    {
      "id": 5123212,
      "title": "연말 총 4조원 규모 종부세 고지서 발송...국민 절반 이상 \"완화 공감\"",
      "time": "2022-11-18T10:45:00",
    },
    {
      "id": 31341,
      "title": "\"이건 지키려했는데\"...동네사장님들, 최후보루마저 손댄다",
      "time": "2022-11-17T20:16:31",
    },
    {
      "id": 4141531,
      "title": "돈줄 막힌 자영업자, 은퇴자금까지 꺼내쓴다",
      "time": "2022-11-17T17:59:00",
    },
    {
      "id": 13456745,
      "title": "금호석유화학, 2030년까지 업무용 차령 친환경차로 전부 바꾼다",
      "time": "2022-11-17T16:06:10",
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _asyncMethod();
    });
  }

  _asyncMethod() async {
    final temp = await AppController.storage.read(key: "notify");
    final List<dynamic> list = json.decode(temp ?? "[]");
    notifyList = list.map((e) => Map<String, dynamic>.from(e)).toList();
    // notifyList = test;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (deleteSign) {
      notifyList = null;
      deleteSign = false;
    }
    return DefaultLayout(
      isNotifyPage: true,
      isExtraPage: false,
      appBarFunction: deleteFunction,
      child: Container(
        color: NEWSTAB_BG_COLOR,
        padding: EdgeInsets.symmetric(horizontal: HORIZONTAL_PADDING.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _head(),
            _list(),
          ],
        ),
      ),
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 5.w, 0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 25.sp,
                      ))),
              Text(
                "뉴스 알림",
                style: TextStyle(
                    fontSize: 35.sp,
                    color: KEYWORD_BG_COLOR,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Text(
            "회원님의 관심사와 관련된 새로운 뉴스를 표시해드립니다.",
            style: TextStyle(fontSize: 13.sp, color: SMALL_FONT_COLOR),
          ),
        ],
      ),
    );
  }

  Widget _list() {
    return Flexible(
      child: SlidableAutoCloseBehavior(
        child: ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (context, i) {
            if (notifyList == null) {
              return Container();
            }
            return NotificationTile.fromNotify(notifyList![i], () async {
              notifyList!.removeAt(i);
              await AppController.storage
                  .write(key: "notify", value: json.encode(notifyList));
              setState(() {});
            });
          },
          separatorBuilder: (context, i) {
            return const Divider(
              thickness: 1.5,
            );
          },
          itemCount: notifyList?.length ?? 0,
          physics: ClampingScrollPhysics(),
        ),
      ),
    );
  }

  deleteFunction() async {
    Future.delayed(
      Duration.zero,
      () => showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text(
            '모든 알림을 지우시겠습니까?',
          ),
          content: Text(
            '지운 알림은 복구가 불가능합니다.',
          ),
          actions: <Widget>[
            PlatformDialogAction(
              child: PlatformText("취소"),
              onPressed: () => Get.back(),
            ),
            PlatformDialogAction(
              child: PlatformText("지우기"),
              onPressed: () async {
                await AppController.storage.write(key: "notify", value: "[]");
                deleteSign = true;
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
    setState(() {});
  }
}

class NotificationTile extends StatefulWidget {
  final String title;
  final DateTime time;
  final int id;
  final Function func;

  const NotificationTile({
    Key? key,
    required this.title,
    required this.time,
    required this.id,
    required this.func,
  }) : super(key: key);

  factory NotificationTile.fromNotify(
      Map<String, dynamic> data, Function func) {
    print("notify : " + data.toString());
    final String title = data["title"];
    final DateTime time = DateTime.parse(data["time"]);
    final int id = data["id"];
    return NotificationTile(
      title: title,
      time: time,
      id: id,
      func: func,
    );
  }

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: Key(widget.id.toString()),
      onDismissed: (_) {
        widget.func();
      },
      child: _tile(),
    );
  }

  routeToNewsDetailPage() {
    Get.to(() => NewsDetailView.fromNewsId(widget.id));
  }

  Widget _tile() {
    final t = widget.time;
    return GestureDetector(
      onTap: () {
        routeToNewsDetailPage();
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')} ${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                  fontSize: 15.sp,
                  color: KEYWORD_BG_COLOR,
                  fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 7.h,
            ),
            Text(
              overflow: TextOverflow.ellipsis,
              widget.title,
              style: TextStyle(
                fontSize: 19.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
