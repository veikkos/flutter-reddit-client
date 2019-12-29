import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/util/formatter.dart';
import 'package:html_unescape/html_unescape.dart';

class Comment {
  Comment(this._text, this._author, this._flair, this._score, this._op);

  final String _text;
  final String _author;
  final String _flair;
  final int _score;
  final bool _op;
  List<Comment> replies = List<Comment>();

  _makeComment(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Flexible(
              child: Text(_author,
                  style: Theme.of(context).textTheme.body2.apply(
                        color: _op ? Colors.blue[800] : Colors.blue,
                      )),
            ),
            SizedBox(width: 7.0),
            if (_flair != null && _flair != '')
              Flexible(
                child: Container(
                  color: Colors.black54,
                  padding: const EdgeInsets.all(1.0),
                  child: Text(_flair,
                      style: Theme.of(context)
                          .textTheme
                          .body2
                          .apply(color: Colors.white)),
                ),
              ),
            if (_flair != null && _flair != '') SizedBox(width: 7.0),
            Flexible(
              child: Text(
                  _score != null
                      ? Formatter.uiCount(_score) + ' points'
                      : 'Score hidden',
                  style: Theme.of(context)
                      .textTheme
                      .body2
                      .apply(color: Colors.black38)),
            ),
          ]),
          SizedBox(height: 2.0),
          Text(new HtmlUnescape().convert(_text)),
        ]);
  }

  renderable(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_author != null) _makeComment(context),
              if (replies != null)
                Container(
                  margin: const EdgeInsets.only(left: 20.0),
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
