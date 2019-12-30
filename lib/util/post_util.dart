import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape.dart';

getMarkdownText(String text) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: <Widget>[
      Flexible(child: MarkdownBody(data: HtmlUnescape().convert(text))),
    ],
  );
}

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
