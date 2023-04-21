

class StringIndicator {
  String key;

  int start = -1;
  int end = -1;

  StringIndicator(this.key,this.start, this.end);

  @override
  String toString() {
    return 'StringIndicator{key: $key, start: $start, end: $end}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringIndicator &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}
