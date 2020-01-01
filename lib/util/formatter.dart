import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:html_unescape/html_unescape_small.dart';

class Formatter {
  static uiCount(int count) {
    return count >= 1000
        ? (count / 1000).toStringAsFixed(1).toString() + 'k'
        : count.toString();
  }

  static renderMarkdownBody(String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(child: MarkdownBody(data: HtmlUnescape().convert(text))),
      ],
    );
  }
}
