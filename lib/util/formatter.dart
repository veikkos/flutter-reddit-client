class Formatter {
  static uiCount(int count) {
    return count >= 1000
        ? (count / 1000).toStringAsFixed(1).toString() + 'k'
        : count.toString();
  }
}
