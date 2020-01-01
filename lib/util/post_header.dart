import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_reddit_app/util/awardings.dart';

import 'formatter.dart';

class PostFooter {
  PostFooter(this._stickied, this._locked, this._score, this._comments,
      this._awardings);

  final bool _stickied;
  final bool _locked;
  final int _score;
  final int _comments;
  final Awardings _awardings;

  static parse(var data) {
    return PostFooter(data['stickied'], data['locked'], data['score'],
        data['num_comments'], Awardings.parse(data['all_awardings']));
  }

  renderable(BuildContext context) {
    return Row(children: <Widget>[
      Container(
          child: Row(children: <Widget>[
        if (_stickied)
          Icon(
            Icons.bookmark,
            color: Colors.lightGreen,
          ),
        if (_stickied) SizedBox(width: 6),
        if (_locked)
          Icon(
            Icons.lock_outline,
            color: Colors.yellow[600],
          ),
        if (_locked) SizedBox(width: 2),
        Transform.rotate(
          angle: -pi / 2,
          child: Icon(
            Icons.forward,
            color: Colors.red,
          ),
        ),
        SizedBox(width: 1),
        Text(
          Formatter.uiCount(_score),
          style: Theme.of(context).textTheme.caption,
        ),
      ])),
      SizedBox(width: 10),
      Container(
        child: Row(children: <Widget>[
          Icon(
            Icons.comment,
            color: Colors.grey,
          ),
          SizedBox(width: 5),
          Text(
            Formatter.uiCount(_comments),
            style: Theme.of(context).textTheme.caption,
          ),
        ]),
      ),
      _awardings.renderable(),
    ]);
  }
}
