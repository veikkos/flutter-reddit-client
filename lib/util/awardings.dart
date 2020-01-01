import 'package:flutter/widgets.dart';

class Awarding {
  Awarding(this.count, this.icon);

  num count;
  String icon;
}

class Awardings {
  Awardings(this._awardings);

  List<Awarding> _awardings;

  renderable() {
    return Flexible(
      child: Wrap(
        children: _awardings
            .where((awardings) => awardings.count > 0)
            .map<Widget>(
              (awardings) => Row(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(width: 7),
                Image.network(
                  awardings.icon,
                  width: 20,
                ),
              ]),
            )
            .toList(),
      ),
    );
  }

  static parse(var data) {
    return Awardings(data
        .map<Awarding>((item) => Awarding(item['count'], item['icon_url']))
        .toList());
  }
}
