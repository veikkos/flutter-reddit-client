import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reddit/reddit.dart';

import 'comment_item.dart';

class CommentsWidget extends StatefulWidget {
  CommentsWidget(this.reddit, this.subreddit, this.id);

  final Reddit reddit;
  final String subreddit;
  final String id;

  @override
  _CommentsWidgetState createState() =>
      _CommentsWidgetState(reddit, subreddit, id);
}

class _CommentsWidgetState extends State<CommentsWidget> {
  _CommentsWidgetState(this._reddit, this._subreddit, this._id);

  final Reddit _reddit;
  final String _subreddit;
  final String _id;
  String _title;
  String _text;
  String _subredditPrefixed;
  List<Comment> _baseComments;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Comments'),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (_subredditPrefixed != null)
                      Text(_subredditPrefixed,
                          style: Theme.of(context).textTheme.body2),
                    if (_subredditPrefixed != null) SizedBox(height: 10.0),
                    if (_title != null)
                      Text(_title, style: Theme.of(context).textTheme.title),
                    if (_text != null) SizedBox(height: 10.0),
                    if (_text != null)
                      Text(_text, style: Theme.of(context).textTheme.body1),
                    Divider(),
                    Text("Comments:",
                        style: Theme.of(context).textTheme.subtitle),
                  ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                  (context, index) => _baseComments[index].renderable(context),
                  childCount: _baseComments != null ? _baseComments.length : 0),
            ),
          ),
        ],
      ),
    );
  }

  static _parseMain(var input) {
    if (input != null && input != '') {
      var highData = input['data'];
      if (highData != null) {
        var children = highData['children'];
        if (children != null) {
          var firstChild = children[0];
          if (firstChild != null) {
            return firstChild['data'];
          }
        }
      }
    }

    return null;
  }

  static _parseReplies(var input) {
    List<Comment> comments;
    if (input != null && input != '') {
      var highData = input['data'];
      if (highData != null) {
        var children = highData['children'];
        if (children != null) {
          children.forEach((reply) {
            var data = reply['data'];
            if (data != null) {
              String body = data['body'];
              String author = data['author'];
              if (body != null && author != null) {
                if (comments == null) comments = new List<Comment>();
                Comment comment = new Comment(
                    body, author, data['score_hidden'] ? null : data['score']);
                var replies = data['replies'];
                if (replies != null) {
                  comment.replies = _parseReplies(replies);
                }
                comments.add(comment);
              }
            }
          });
        }
      }
    }
    return comments;
  }

  @override
  void initState() {
    super.initState();
    _reddit.sub(_subreddit).comments(_id).fetch().then((result) {
      setState(() {
        var data = result['data'];
        var main = _parseMain(data[0]);
        _title = main['title'];
        _text = main['selftext'];
        _subredditPrefixed = main['subreddit_name_prefixed'];
        if (_text != null && _text == '') _text = null;
        _baseComments = _parseReplies(data[1]);
      });
    });
  }
}
