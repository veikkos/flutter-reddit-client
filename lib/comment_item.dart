import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'formatter.dart';

class Comment {
  Comment(this.text, this.author, this.score);

  final String text;
  final String author;
  final int score;
  List<Comment> replies = List<Comment>();

  _makeComment(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(children: <Widget>[
            Text(author,
                style: Theme.of(context).textTheme.caption.apply(
                      color: Colors.blue,
                    )),
            SizedBox(width: 5.0),
            Text(
                score != null
                    ? Formatter.uiCount(score) + ' points'
                    : 'Score hidden',
                style: Theme.of(context).textTheme.caption),
          ]),
          Text(text),
        ]);
  }

  renderable(BuildContext context) {
    return Container(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          if (author != null) _makeComment(context),
          if (replies != null)
            Container(
              margin:
                  const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.separated(
                  itemBuilder: (context, index) =>
                      replies[index].renderable(context),
                  itemCount: replies.length,
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                ),
              ),
            )
        ]));
  }
}
