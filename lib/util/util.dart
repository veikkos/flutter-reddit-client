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

getSubredditAppBar(
    String title, String subreddit, String icon, String headerImg) {
  return SliverAppBar(
    backgroundColor: icon != null ? Colors.black : null,
    title: icon != null ? null : Text(title),
    expandedHeight: icon != null ? 130.0 : 0,
    flexibleSpace: icon != null
        ? FlexibleSpaceBar(
            centerTitle: true,
            title: icon != null
                ? Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: new BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                        radius: 32, backgroundImage: NetworkImage(icon)),
                  )
                : Text(subreddit),
            background: headerImg != null
                ? Opacity(
                    opacity: 0.7,
                    child: Image.network(
                      headerImg,
                      fit: BoxFit.cover,
                    ),
                  )
                : null)
        : null,
  );
}

class Awardings {
  Awardings(this.count, this.icon);

  num count;
  String icon;
}

getAwardings(List<Awardings> awardings) {
  return awardings
      .where((awardings) => awardings.count > 0)
      .map<Widget>((awardings) => Row(children: [
            SizedBox(width: 7),
            Image.network(
              awardings.icon,
              width: 20,
            ),
          ]));
}

parseAwardings(var data) {
  return data
      .map<Awardings>((item) => Awardings(item['count'], item['icon_url']))
      .toList();
}
