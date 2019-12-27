import 'package:flutter/material.dart';
import 'package:flutter_reddit_app/comments_widget.dart';
import 'package:flutter_reddit_app/reddit_secrets.dart';
import 'package:reddit/reddit.dart';
import 'package:http/http.dart' as http;

import 'post_item.dart';

void main() {
  Reddit reddit = new Reddit(new http.Client());
  reddit.authSetup(RedditSecrets.identifier, RedditSecrets.secret);
  reddit.authFinish();

  runApp(RedditApp(reddit));
}

class RedditApp extends StatelessWidget {
  RedditApp(this.reddit);

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
  List<PostItem> items = new List<PostItem>();

  void _refresh() {
    if (_subreddit != null && _subreddit.isNotEmpty)
      _reddit.sub(_subreddit).hot().limit(20).fetch().then((result) {
        setState(() {
          var data = result['data'];
          if (data != null && data != '') {
            items = data['children'].map<PostItem>((d) {
              var data = d['data'];
              return new PostItem(
                  data['id'],
                  data['title'],
                  data['subreddit'],
                  data['subreddit_name_prefixed'],
                  data['author_fullname'],
                  data['score'],
                  data['num_comments'],
                  data['likes'],
                  data['thumbnail'].toString().contains('http')
                      ? data['thumbnail']
                      : null);
            }).toList();
          }
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text(widget.title),
            floating: true,
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 10.0, left: 20, bottom: 0),
              child: Column(children: <Widget>[
                TextField(
                  controller: TextEditingController()..text = _subreddit,
                  style: new TextStyle(
                    fontSize: 24.0,
                  ),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixText: 'r/',
                      hintText: 'Input subreddit name'),
                  onSubmitted: (text) {
                    _subreddit = text;
                    _refresh();
                  },
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
                          return CommentsWidget(
                              _reddit,
                              items[indexFixed].getSubreddit(),
                              items[indexFixed].getId());
                        }),
                      );
                    },
                    child: items[index ~/ 2].renderable(context));
              }, childCount: (items.length * 2) - 1),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }
}
