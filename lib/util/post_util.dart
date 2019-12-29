import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

getPostHeader(BuildContext context, String subredditPrefixed, String user) {
  return Row(children: <Widget>[
    Text(
      subredditPrefixed,
      style: Theme.of(context).textTheme.body2,
    ),
    SizedBox(width: 10),
    Flexible(
      child: Text(
        'Posted by u/' + user,
        style: Theme.of(context).textTheme.body1.apply(
              color: Colors.black54,
            ),
      ),
    ),
  ]);
}
