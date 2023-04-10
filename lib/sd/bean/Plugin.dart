
class Plugin{

  bool checked = false;
  String prefix;
  String name;
  double weight = 1.0;

  Plugin(this.prefix, this.name);

  @override
  String toString() {
   return '$prefix:$name';
  }

  @override
  bool operator == (Object other) {
    return '$prefix:$name' == other.toString();
  }

}