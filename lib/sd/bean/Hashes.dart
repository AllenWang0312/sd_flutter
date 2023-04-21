class Hashes {
  Hashes({
      this.vae, 
      this.model,});

  Hashes.fromJson(dynamic json) {
    vae = json['vae'];
    model = json['model'];
  }
  String? vae;
  String? model;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['vae'] = vae;
    map['model'] = model;
    return map;
  }

}