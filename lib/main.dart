import 'package:flutter/material.dart';
import 'package:flutter_reddit_app/posts/posts_widget.dart';
import 'package:flutter_reddit_app/reddit_secrets.dart';
import 'package:http/http.dart' as http;
import 'package:reddit/reddit.dart';

void main() {
  Reddit reddit = new Reddit(new http.Client());
  reddit.authSetup(RedditSecrets.identifier, RedditSecrets.secret);
  reddit.authFinish();

  runApp(PostsWidget(reddit));
}
