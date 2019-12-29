import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/posts/post_item.dart';
import 'package:flutter_reddit_app/posts/subreddit_info.dart';
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
  SubredditInfo _subreddit = SubredditInfo('all');
  List<PostItem> _items = new List<PostItem>();

  _refreshPosts() {
    if (_subreddit.name.isNotEmpty) {
      try {
        _reddit.sub(_subreddit.name).hot().fetch().then((result) {
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
      } on RedditApiException catch (e) {
        print(e);
      }
    }
  }

  _getSubredditInfo() {
    try {
      _reddit.sub(_subreddit.name).about().fetch().then((result) {
        var data = result['data'];
        if (data != null) {
          setState(() {
            var bannerImg = data['banner_img'];
            var bannerBackgroundImage = data['banner_background_image'];
            var iconImg = data['icon_img'];
            _subreddit = SubredditInfo(_subreddit.name,
                title: data['title'],
                headerImg: bannerImg != null && bannerImg != ''
                    ? bannerImg
                    : bannerBackgroundImage != ''
                        ? bannerBackgroundImage
                        : null,
                icon: iconImg != null && iconImg != '' ? iconImg : null);
          });
        }
      });
    } on RedditApiException catch (e) {
      print(e);
    }
  }

  _getSubredditList(String pattern) async {
    var completer = new Completer<List<String>>();
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

  _updateSubreddit(String subreddit) {
    _subreddit = SubredditInfo(subreddit);
    _refreshPosts();
    _getSubredditInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: _subreddit.icon != null ? Colors.black : null,
            title: _subreddit.icon != null ? null : Text(widget.title),
            expandedHeight: _subreddit.icon != null ? 130.0 : 0,
            flexibleSpace: _subreddit.icon != null
                ? FlexibleSpaceBar(
                    centerTitle: true,
                    title: _subreddit.icon != null
                        ? Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: new BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                                radius: 32,
                                backgroundImage: NetworkImage(_subreddit.icon)),
                          )
                        : Text(_subreddit.title),
                    background: _subreddit.headerImg != null
                        ? Opacity(
                            opacity: 0.7,
                            child: Image.network(
                              _subreddit.headerImg,
                              fit: BoxFit.cover,
                            ),
                          )
                        : null)
                : null,
          ),
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
                              ..text = _subreddit.name,
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
                    ),
                  ],
                ),
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
    _getSubredditInfo();
  }
}
