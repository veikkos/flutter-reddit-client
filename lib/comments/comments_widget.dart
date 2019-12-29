import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_reddit_app/util/post_util.dart';
import 'package:reddit/reddit.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_reddit_app/comments/comment_item.dart';

class CommentsWidget extends StatefulWidget {
  CommentsWidget(this._reddit, this._subreddit, this._author, this._id);

  final Reddit _reddit;
  final String _subreddit;
  final String _author;
  final String _id;

  @override
  _CommentsWidgetState createState() =>
      _CommentsWidgetState(_reddit, _subreddit, _author, _id);
}

class _CommentsWidgetState extends State<CommentsWidget> {
  _CommentsWidgetState(this._reddit, this._subreddit, this._author, this._id);

  final Reddit _reddit;
  final String _subreddit;
  final String _author;
  final String _id;
  String _title;
  String _text;
  String _subredditPrefixed;
  String _url;
  List<Comment> _baseComments;
  bool loading = true;

  _getContent() {
    if (_url.endsWith('.gif') || _url.endsWith('.jpg')) {
      return Image.network(_url);
    } else {
      return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Icon(
          Icons.link,
          color: Colors.blueAccent,
        ),
        SizedBox(width: 2.0),
        Flexible(
          child: Linkify(
              text: _url,
              humanize: true,
              onOpen: (LinkableElement link) {
                if (canLaunch(link.url) != null) {
                  launch(link.url);
                }
              }),
        )
      ]);
    }
  }

  List<Widget> _getView() {
    return loading
        ? [
            SliverToBoxAdapter(
                child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                  SizedBox(height: 100.0),
                  CircularProgressIndicator()
                ]))
          ]
        : [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      getPostHeader(context, _subredditPrefixed, _author),
                      if (_subredditPrefixed != null) SizedBox(height: 10.0),
                      if (_title != null)
                        Text(_title, style: Theme.of(context).textTheme.title),
                      if (_text != null || _url != null) SizedBox(height: 10.0),
                      if (_text != null)
                        Text(_text, style: Theme.of(context).textTheme.body1),
                      if (_url != null) _getContent(),
                      Divider(),
                      Text("Comments:",
                          style: Theme.of(context).textTheme.subtitle),
                    ]),
              ),
            ),
            SliverPadding(
              padding:
                  const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    (context, index) =>
                        _baseComments[index].renderable(context),
                    childCount:
                        _baseComments != null ? _baseComments.length : 0),
              ),
            )
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Comments'),
            floating: true,
          ),
          ..._getView(),
        ],
      ),
    );
  }

  static _parsePostInfo(var input) {
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
                    body,
                    author,
                    data['author_flair_text'],
                    data['score_hidden'] ? null : data['score'],
                    data['is_submitter']);
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

  _fetchComments() {
    try {
      _reddit.sub(_subreddit).comments(_id).fetch().then((result) {
        setState(() {
          loading = false;
          var data = result['data'];
          var postInfo = _parsePostInfo(data[0]);
          _title = postInfo['title'];
          _text = postInfo['selftext'];
          _url = postInfo['url'];
          _subredditPrefixed = postInfo['subreddit_name_prefixed'];
          if (_text == '') _text = null;
          _baseComments = _parseReplies(data[1]);
        });
      });
    } on RedditApiException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }
}
