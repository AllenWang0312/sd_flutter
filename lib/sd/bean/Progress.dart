class Progress {
  Progress({
      this.active, 
      this.queued, 
      this.completed, 
      this.progress, 
      this.eta, 
      this.livePreview, 
      this.idLivePreview, 
      this.textinfo,});

  Progress.fromJson(dynamic json) {
    active = json['active'];
    queued = json['queued'];
    completed = json['completed'];
    progress = json['progress'];
    eta = json['eta'];
    livePreview = json['live_preview'];
    idLivePreview = json['id_live_preview'];
    textinfo = json['textinfo'];
  }
  bool active;
  bool queued;
  bool completed;
  double progress;
  double eta;
  String livePreview;
  int idLivePreview;
  dynamic textinfo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['active'] = active;
    map['queued'] = queued;
    map['completed'] = completed;
    map['progress'] = progress;
    map['eta'] = eta;
    map['live_preview'] = livePreview;
    map['id_live_preview'] = idLivePreview;//data:image/png;base64,datas...
    map['textinfo'] = textinfo;
    return map;
  }

}