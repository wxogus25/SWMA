import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tot/common/data/API.dart';
import 'package:tot/common/data/cache.dart';
import 'package:tot/common/data/news_tile_data.dart';
import 'package:tot/common/view/news_detail_view.dart';

import '../const/colors.dart';

class NewsTile extends StatefulWidget {
  final String? stockName;
  final String postingDate;
  final String newsTitle;
  final int id;
  final List<String> tagList;

  const NewsTile(
      {required this.tagList,
      required this.postingDate,
      required this.newsTitle,
      required this.id,
      this.stockName,
      Key? key})
      : super(key: key);

  factory NewsTile.fromData(NewsTileData data) {
    return NewsTile(
      tagList: data.keywords,
      postingDate: data.created_at,
      newsTitle: data.title,
      stockName: data.attention_stock,
      id: data.id,
    );
  }

  @override
  State<NewsTile> createState() => _NewsTileState();
}

int checkBookmark(int id) {
  if (userBookmark.contains(id)) {
    return 1;
  } else {
    return 0;
  }
}

class _NewsTileState extends State<NewsTile> {
  List<IconData> toggleIcon = [Icons.bookmark_border, Icons.bookmark];
  late int toggle;

  @override
  initState() {
    super.initState();
    toggle = checkBookmark(widget.id);
  }

  routeToNewsDetailPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NewsDetailView.fromNewsTile(widget),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      groupTag: "tile",
      // Specify a key if the Slidable is dismissible.
      key: const ValueKey(0),
      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        extentRatio: 0.15,
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            // autoClose: false,
            onPressed: (BuildContext context) {
              var snackbar;
              if (toggle == 0) {
                userBookmark.add(widget.id);
                API.createBookmarkById(widget.id);
                snackbar = SnackBar(
                  content: Text("북마크에 추가했습니다."),
                  duration: Duration(milliseconds: 1500),
                  action: SnackBarAction(
                    label: '취소',
                    onPressed: () {
                      userBookmark.remove(widget.id);
                      API.deleteBookmarkById(widget.id);
                      setState(() {
                        toggle ^= 1;
                      });
                    },
                  ),
                );
              }
              if (toggle == 1) {
                userBookmark.remove(widget.id);
                API.deleteBookmarkById(widget.id);
                snackbar = SnackBar(
                  content: Text("북마크에서 삭제했습니다."),
                  duration: Duration(milliseconds: 1500),
                  action: SnackBarAction(
                    label: '취소',
                    onPressed: () {
                      userBookmark.add(widget.id);
                      API.createBookmarkById(widget.id);
                      setState(() {
                        toggle ^= 1;
                      });
                    },
                  ),
                );
              }
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
              setState(() {
                toggle ^= 1;
              });
            },
            backgroundColor: Colors.transparent,
            foregroundColor: PRIMARY_COLOR,
            icon: toggleIcon[toggle],
            label: '북마크',
            padding: EdgeInsets.symmetric(horizontal: 10),
            borderRadius: BorderRadius.circular(30),
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: GestureDetector(
        onTap: () {
          routeToNewsDetailPage(context);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.newsTitle,
                style: TextStyle(fontSize: 19),
                overflow: TextOverflow.ellipsis,
              ),
              Container(
                height: 25,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.stockName == null)
                      SizedBox.shrink()
                    else
                      stockTag(),
                    ...keywordTags(),
                    Spacer(),
                    Text(
                      widget.postingDate,
                      style: TextStyle(
                          fontSize: 11,
                          color: SMALL_FONT_COLOR,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget stockTag() {
    return Container(
      padding: const EdgeInsets.all(0.0),
      margin: const EdgeInsets.fromLTRB(0, 0, 7, 0),
      width: 70,
      height: 18,
      child: ElevatedButton(
        onPressed: null,
        child: Text(
          widget.stockName!,
          style: TextStyle(fontSize: 13),
        ),
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 5)),
          // minimumSize: MaterialStateProperty.all<Size>(Size(66, 16)),
          // maximumSize: MaterialStateProperty.all<Size>(Size(66, 16)),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          backgroundColor: MaterialStateProperty.all<Color>(KEYWORD_BG_COLOR),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
      keywordName + " ",
      style: TextStyle(
        fontSize: 13,
        color: SMALL_FONT_COLOR,
      ),
    );
  }
}
