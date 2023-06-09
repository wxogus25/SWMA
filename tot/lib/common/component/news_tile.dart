import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:tot/common/data/BookmarkCache.dart';
import 'package:tot/common/data/news_tile_data.dart';
import 'package:tot/common/view/news_detail_view.dart';
import 'package:tot/common/const/tot_custom_icons_icons.dart';

import '../const/colors.dart';

class NewsTile extends StatefulWidget {
  final String? stockName;
  final String postingDate;
  final String newsTitle;
  final String summary;
  final int id;
  final int label;
  final List<String> tagList;
  final NewsTileData data;
  final bool? isBookmarkPage;

  const NewsTile(
      {required this.tagList,
      required this.postingDate,
      required this.newsTitle,
      required this.id,
      required this.summary,
      required this.label,
      required this.data,
      this.stockName,
      this.isBookmarkPage,
      Key? key})
      : super(key: key);

  factory NewsTile.fromData(NewsTileData data, {bool fix = false}) {
    return NewsTile(
      label: data.label,
      tagList: data.keywords,
      postingDate: data.created_at,
      newsTitle: data.title,
      stockName: data.attention_stock,
      id: data.id,
      summary: data.summary,
      data: data,
      isBookmarkPage: fix,
    );
  }

  @override
  State<NewsTile> createState() => _NewsTileState();
}

int checkBookmark(int id) {
  if (BookmarkCache.to.bookmarks.any((element) => element.id == id)) {
    return 1;
  } else {
    return 0;
  }
}

class _NewsTileState extends State<NewsTile> {
  bool _expanded = false;
  List<IconData> toggleIcon = [
    ToTCustomIcons.slide_bookmark_off,
    ToTCustomIcons.slide_bookmark_on
  ];
  late int toggle;

  @override
  initState() {
    super.initState();
    toggle = checkBookmark(widget.id);
  }

  routeToNewsDetailPage() {
    Get.to(() => NewsDetailView.fromNewsId(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return _slidableWidget(_newsTile());
  }

  Widget _expansionPanel(Widget contain) {
    return ExpansionPanelList(
      children: [
        ExpansionPanel(
          backgroundColor: Colors.transparent,
          headerBuilder: (context, isExpanded) {
            return contain;
          },
          body: Container(
            decoration: BoxDecoration(
              border: Border.all(width: 1.w, color: Colors.grey),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(15),
                top: Radius.circular(15),
              ),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      widget.newsTitle,
                      style: TextStyle(
                          fontSize: 17.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  SizedBox(
                    height: 5.h,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                    child: Text(
                      widget.summary,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ),
          ),
          isExpanded: _expanded,
        ),
      ],
      elevation: 0,
      expandedHeaderPadding: EdgeInsets.zero,
      expansionCallback: (panelIndex, isExpanded) {
        _expanded = !_expanded;
        setState(() {});
      },
    );
  }

  Widget _slidableWidget(Widget child) {
    final BookmarkCache c = BookmarkCache.to;
    return Slidable(
      groupTag: "tile",
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              var snackbar = null;
              if (!c.contain(widget.id)) {
                c.createBookmark(widget.data);
                final id = widget.id;
                snackbar = SnackBar(
                  content: Text("북마크에 추가했습니다."),
                  duration: Duration(milliseconds: 1500),
                  action: SnackBarAction(
                    label: '취소',
                    onPressed: () {
                      c.deleteBookmark(id);
                      if (mounted) {
                        setState(() {
                          toggle ^= 1;
                        });
                      }
                    },
                  ),
                );
              } else if (c.contain(widget.id)) {
                c.deleteBookmark(widget.id);
                final data = widget.data;
                snackbar = SnackBar(
                  content: Text("북마크에서 삭제했습니다."),
                  duration: Duration(milliseconds: 1500),
                  action: SnackBarAction(
                    label: '취소',
                    onPressed: () {
                      c.createBookmark(data);
                      if (mounted) {
                        setState(() {
                          toggle ^= 1;
                        });
                      }
                    },
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              if (mounted) {
                setState(() {
                  toggle ^= 1;
                });
              }
            },
            backgroundColor: Colors.transparent,
            foregroundColor: PRIMARY_COLOR,
            icon: (widget.isBookmarkPage ?? false)
                ? toggleIcon[1]
                : toggleIcon[toggle],
            label: '북마크',
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            borderRadius: BorderRadius.circular(30),
          ),
        ],
      ),
      child: _expansionPanel(_newsTile()),
    );
  }

  Widget _newsTile() {
    return GestureDetector(
      onTap: () {
        routeToNewsDetailPage();
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.newsTitle,
              style: TextStyle(fontSize: 19.sp),
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              height: 25.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.stockName == null)
                    SizedBox.shrink()
                  else
                    stockTag(widget.label),
                  ...keywordTags(),
                  Spacer(),
                  Text(
                    widget.postingDate,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: SMALL_FONT_COLOR,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget stockTag(int val) {
    Color color;
    if (val == 0) {
      color = Color(0xFF909090);
    } else if (val == 1) {
      color = Color(0xFF29ab23);
    } else {
      color = Color(0xFFedcc15);
    }
    return Container(
      padding: const EdgeInsets.all(0.0),
      margin: EdgeInsets.fromLTRB(0, 0, 7.w, 0),
      width: 70.w,
      height: 18.h,
      child: ElevatedButton(
        onPressed: null,
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 5.w)),
          // minimumSize: MaterialStateProperty.all<Size>(Size(66, 16)),
          // maximumSize: MaterialStateProperty.all<Size>(Size(66, 16)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            widget.stockName!,
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
      ),
    );
  }

  List<Widget> keywordTags() {
    return List.from(
      widget.tagList.map(
        (keyword) => KeywordTag(
          keywordName: ("#$keyword"),
        ),
      ),
    );
  }
}

class KeywordTag extends StatelessWidget {
  final String keywordName;

  const KeywordTag({required this.keywordName, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "$keywordName ",
      style: TextStyle(
        fontSize: 13.sp,
        color: SMALL_FONT_COLOR,
      ),
    );
  }
}
