import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/util/header.dart';
import 'package:flutter_reddit_app/util/post_header.dart';
import 'package:html_unescape/html_unescape_small.dart';

class PostItem {
  final String id;
  final String title;
  final String subreddit;
  final Header _header;
  final PostFooter postFooter;
  final String thumbnailUrl;

  PostItem(this.id, this.title, this.subreddit, this._header, this.postFooter,
      this.thumbnailUrl);

  renderable(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      child: Column(children: <Widget>[
        _header.renderable(context),
        Column(children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
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
                      HtmlUnescape().convert(title),
                      style: Theme.of(context).textTheme.body1,
                    ),
                  ),
                ]),
          ),
          postFooter.renderable(context),
        ])
      ]),
    );
  }
}
