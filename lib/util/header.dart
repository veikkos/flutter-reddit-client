import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:timeago/timeago.dart' as timeAgo;

class Header {
  Header(this.subredditPrefixed, this.user, this.created);

  String subredditPrefixed;
  String user;
  num created;

  static parse(var data) {
    return Header(
        data['subreddit_name_prefixed'], data['author'], data['created_utc']);
  }

  renderable(BuildContext context) {
    String time = timeAgo.format(DateTime.fromMillisecondsSinceEpoch(
        created.toInt() * 1000,
        isUtc: true));
    return Row(children: <Widget>[
      Text(
        subredditPrefixed,
        style: Theme.of(context).textTheme.body2,
      ),
      SizedBox(width: 10),
      Flexible(
        child: Text(
          'By u/$user $time',
          style: Theme.of(context).textTheme.body1.apply(
                color: Colors.black54,
              ),
        ),
      ),
    ]);
  }
}
