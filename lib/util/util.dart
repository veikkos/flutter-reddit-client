import 'package:flutter/material.dart';

getSubredditAppBar(
    String title, String subreddit, String icon, String headerImg) {
  return SliverAppBar(
    backgroundColor: icon != null ? Colors.black : null,
    title: icon != null ? null : Text(title),
    expandedHeight: icon != null ? 130.0 : 0,
    flexibleSpace: icon != null
        ? FlexibleSpaceBar(
            centerTitle: true,
            title: icon != null
                ? Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: new BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                        radius: 32, backgroundImage: NetworkImage(icon)),
                  )
                : Text(subreddit),
            background: headerImg != null
                ? Opacity(
                    opacity: 0.7,
                    child: Image.network(
                      headerImg,
                      fit: BoxFit.cover,
                    ),
                  )
                : null)
        : null,
  );
}
