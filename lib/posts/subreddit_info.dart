import 'dart:async';

import 'package:reddit/reddit.dart';

class SubredditInfo {
  SubredditInfo(this.name, {this.title, this.headerImg, this.icon});

  String name;
  String title;
  String headerImg;
  String icon;

  get hasData => title != null || headerImg != null || icon != null;

  static Future<SubredditInfo> getSubredditInfo(Reddit reddit, String subreddit) async {
    var completer = Completer<SubredditInfo>();
    try {
      reddit.sub(subreddit).about().fetch().then((result) {
        var data = result['data'];
        if (data != null) {
          var bannerImg = data['banner_img'];
          var bannerBackgroundImage = data['banner_background_image'];
          var iconImg = data['icon_img'];
          return completer.complete(SubredditInfo(subreddit,
              title: data['title'],
              headerImg: bannerImg != null && bannerImg != ''
                  ? bannerImg
                  : bannerBackgroundImage != '' ? bannerBackgroundImage : null,
              icon: iconImg != null && iconImg != '' ? iconImg : null));
        }

        completer.complete(null);
      });
    } on RedditApiException catch (e) {
      print(e);
      completer.complete(null);
    }
    return completer.future;
  }

  static all() => SubredditInfo('all');
}
