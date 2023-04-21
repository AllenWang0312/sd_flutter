class Option {
  Option({
      this.scheduler, 
      this.discardNextToLastSigma,});

  Option.fromJson(dynamic json) {
    scheduler = json['scheduler'];
    discardNextToLastSigma = json['discard_next_to_last_sigma'];
  }
  String? scheduler;
  String? discardNextToLastSigma;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['scheduler'] = scheduler;
    map['discard_next_to_last_sigma'] = discardNextToLastSigma;
    return map;
  }

}