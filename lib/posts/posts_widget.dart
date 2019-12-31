import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/comments/comments_widget.dart';
import 'package:flutter_reddit_app/posts/post_item.dart';
import 'package:flutter_reddit_app/posts/subreddit_info.dart';
import 'package:flutter_reddit_app/util/util.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:reddit/reddit.dart';

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
  SubredditInfo _subredditInfo = SubredditInfo.all();
  List<PostItem> _items = List<PostItem>();

  _refreshPosts(String subredditName) {
    try {
      _reddit.sub(subredditName).hot().fetch().then((result) {
        setState(() {
          var data = result['data'];
          if (data != null && data != '') {
            _items = data['children'].map<PostItem>((d) {
              var data = d['data'];
              return PostItem(
                  data['created_utc'],
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
                  data['stickied'],
                  parseAwardings(data['all_awardings']));
            }).toList();
          }
        });
      });
    } on RedditApiException catch (e) {
      print(e);
    }
  }

  _getSubredditList(String pattern) async {
    var completer = Completer<List<String>>();
    try {
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
    } on RedditApiException catch (e) {
      print(e);
      return completer.complete(List<String>());
    }

    return completer.future;
  }

  _updateSubredditInfo(SubredditInfo subredditInfo) {
    setState(() {
      _subredditInfo = subredditInfo;
    });
    _refreshPosts(subredditInfo.name);
  }

  _updateSubreddit(String subreddit) async {
    if (subreddit == 'all') {
      _updateSubredditInfo(SubredditInfo.all());
    } else {
      SubredditInfo.getSubredditInfo(_reddit, subreddit).then((subredditInfo) {
        if (subredditInfo != null) {
          _updateSubredditInfo(subredditInfo);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          getSubredditAppBar(widget.title, _subredditInfo.title,
              _subredditInfo.icon, _subredditInfo.headerImg),
          SliverToBoxAdapter(
            child: Container(
              padding:
                  const EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
              child: Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.search),
                    SizedBox(width: 5.0),
                    Expanded(
                      child: TypeAheadField(
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: TextEditingController()
                              ..text = _subredditInfo.name,
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixText: 'r/',
                                hintText: 'type subreddit (e.g. "all")'),
                            onSubmitted: (subreddit) {
                              _updateSubreddit(subreddit);
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
                          onSuggestionSelected: (subreddit) {
                            _updateSubreddit(subreddit);
                          },
                          noItemsFoundBuilder: (BuildContext context) => null),
                    ),
                  ],
                ),
                Divider(
                  thickness: 3.0,
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index.isOdd) {
                  return Divider(
                    thickness: 2.0,
                  );
                }
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          var indexFixed = index ~/ 2;
                          var item = _items[indexFixed];
                          return CommentsWidget(
                              _reddit,
                              item.subreddit.toLowerCase() ==
                                      _subredditInfo.name.toLowerCase()
                                  ? _subredditInfo
                                  : SubredditInfo(item.subreddit),
                              item.author,
                              item.id);
                        }),
                      );
                    },
                    child: _items[index ~/ 2].renderable(context));
              }, childCount: max(_items.length * 2 - 1, 0)),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshPosts(_subredditInfo.name),
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshPosts(_subredditInfo.name);
  }
}
