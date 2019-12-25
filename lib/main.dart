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
  _RedditPageState(this.reddit);

  Reddit reddit;
  List<PostItem> items = new List<PostItem>();

  void _refresh() {
    reddit.frontPage.hot().limit(20).fetch().then((result) {
      setState(() {
        items = result['data']['children'].map<PostItem>((d) {
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
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CommentsWidget(reddit,
                            items[index].getSubreddit(), items[index].getId())),
                  );
                },
                child: items[index].renderable(context));
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
        ),
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
