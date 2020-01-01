import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/util/awardings.dart';
import 'package:flutter_reddit_app/util/formatter.dart';

class Comment {
  Comment(this._text, this._author, this._flair, this._score, this._op,
      this._awardings, this.distinguished);

  final String _text;
  final String _author;
  final String _flair;
  final int _score;
  final bool _op;
  final Awardings _awardings;
  final bool distinguished;
  List<Comment> replies = List<Comment>();

  _makeComment(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              Flexible(
                child: Text(_author,
                    style: Theme.of(context).textTheme.body2.apply(
                          color: distinguished
                              ? Colors.green
                              : _op
                                  ? Theme.of(context).primaryColorDark
                                  : Theme.of(context).primaryColor,
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
              if (_awardings.getAwardings().length > 0) _awardings.renderable(),
            ]),
          ),
          SizedBox(height: 2.0),
          Formatter.renderMarkdownBody(_text),
        ]);
  }

  _makeWrappedComment(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [if (_author != null) _makeComment(context)]));
  }

  renderable(BuildContext context) {
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return replies != null
        ? Theme(
            data: theme,
            child: ListTileTheme(
              contentPadding: const EdgeInsets.all(0),
              child: ExpansionTile(
                initiallyExpanded: true,
                title: _makeWrappedComment(context),
                trailing: null,
                children: [
                  Container(
                    margin: const EdgeInsets.only(left: 20.0),
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        itemBuilder: (context, index) =>
                            replies[index].renderable(context),
                        itemCount: replies.length,
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        : _makeWrappedComment(context);
  }
}
