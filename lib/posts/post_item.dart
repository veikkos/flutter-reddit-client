import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/util/formatter.dart';
import 'package:flutter_reddit_app/util/post_util.dart';

class PostItem {
  final String id;
  final String title;
  final String subreddit;
  final String subredditPrefixed;
  final String author;
  final int score;
  final int comments;
  final String url;
  final String thumbnailUrl;
  final bool locked;
  final bool stickied;

  PostItem(
      this.id,
      this.title,
      this.subreddit,
      this.subredditPrefixed,
      this.author,
      this.score,
      this.comments,
      this.url,
      this.thumbnailUrl,
      this.locked,
      this.stickied);

  renderable(BuildContext context) {
    return new Container(
      margin:
          const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Column(children: <Widget>[
        getPostHeader(context, subredditPrefixed, author),
        Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (thumbnailUrl != null)
                    ClipRRect(
                        borderRadius: BorderRadius.circular(3.0),
                        child: Image.network(thumbnailUrl, width: 80.0)),
                  if (thumbnailUrl != null) SizedBox(width: 10.0),
                  Flexible(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),
                ]),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
            Container(
                child: Row(children: <Widget>[
              if (stickied)
                Icon(
                  Icons.bookmark,
                  color: Colors.lightGreen,
                ),
              if (stickied) SizedBox(width: 6),
              if (locked)
                Icon(
                  Icons.lock_outline,
                  color: Colors.yellow[600],
                ),
              if (locked) SizedBox(width: 2),
              Transform.rotate(
                angle: -pi / 2,
                child: Icon(
                  Icons.forward,
                  color: Colors.red,
                ),
              ),
              SizedBox(width: 1),
              Text(
                Formatter.uiCount(score),
                style: Theme.of(context).textTheme.caption,
              ),
            ])),
            SizedBox(width: 10),
            Container(
              child: Row(children: <Widget>[
                Icon(
                  Icons.comment,
                  color: Colors.grey,
                ),
                SizedBox(width: 5),
                Text(
                  Formatter.uiCount(comments),
                  style: Theme.of(context).textTheme.caption,
                ),
              ]),
            ),
          ])
        ])
      ]),
    );
  }
}
