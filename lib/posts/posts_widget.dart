import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/posts/post_item.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:reddit/reddit.dart';

import 'package:flutter_reddit_app/comments/comments_widget.dart';

class PostsWidget extends StatelessWidget {
  PostsWidget(this.reddit);

  final Reddit reddit;
  static final String appName = 'Passive Reddit (unofficial)';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: RedditPage(title: appName, reddit: reddit),
    );
  }
}

class RedditPage extends StatefulWidget {
  RedditPage({Key key, this.title, this.reddit}) : super(key: key);

  final Reddit reddit;
  final String title;

  @override
  _RedditPageState createState() => _RedditPageState(reddit);
}

class _RedditPageState extends State<RedditPage> {
  _RedditPageState(this._reddit);

  Reddit _reddit;
  String _subreddit = 'all';
  List<PostItem> _items = new List<PostItem>();

  _refreshPosts() {
    if (_subreddit != null && _subreddit.isNotEmpty)
      _reddit.sub(_subreddit).hot().limit(20).fetch().then((result) {
        setState(() {
          var data = result['data'];
          if (data != null && data != '') {
            _items = data['children'].map<PostItem>((d) {
              var data = d['data'];
              return new PostItem(
                  data['id'],
                  data['title'],
                  data['subreddit'],
                  data['subreddit_name_prefixed'],
                  data['author'],
                  data['score'],
                  data['num_comments'],
                  data['likes'],
                  data['thumbnail'].toString().contains('http')
                      ? data['thumbnail']
                      : null,
                  data['locked'],
                  data['stickied']);
            }).toList();
          }
        });
      });
  }

  _getSubredditList(String pattern) async {
    var completer = new Completer<List<String>>();
    _reddit.popularSubreddits().fetch().then((result) {
      var data = result['data'];
      if (data != null) {
        var children = data['children'];
        if (children != null) {
          var list = children
              .map<String>((item) => item['data']['display_name'].toString())
              .toList();
          list.sort();
          return completer.complete(list.where((sub) {
            return sub.toLowerCase().contains(pattern.toLowerCase()) == true;
          }).toList());
        }
      }

      return completer.complete(List<String>());
    });

    return completer.future;
  }

  _updateSubreddit(String subreddit) {
    _subreddit = subreddit;
    _refreshPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(widget.title),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 10.0, left: 20.0),
              child: Column(children: <Widget>[
                TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: TextEditingController()..text = _subreddit,
                      style: new TextStyle(
                        fontSize: 24.0,
                      ),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixText: 'r/',
                          hintText: 'type subreddit (e.g. "all")'),
                      onSubmitted: (text) {
                        _updateSubreddit(text);
                      },
                    ),
                    suggestionsCallback: (pattern) async {
                      return await _getSubredditList(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) {
                      _updateSubreddit(suggestion);
                    },
                    noItemsFoundBuilder: (BuildContext context) => null),
                Divider(),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) {
                  return Divider();
                }
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          var indexFixed = index ~/ 2;
                          var item = _items[indexFixed];
                          return CommentsWidget(
                              _reddit, item.subreddit, item.author, item.id);
                        }),
                      );
                    },
                    child: _items[index ~/ 2].renderable(context));
              }, childCount: (_items.length * 2) - 1),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshPosts,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshPosts();
  }
}
