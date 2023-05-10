class Cmd {
  Cmd({
      this.refreshModel = 0,
      this.cleanSeed = 0,
      this.setX = 0,
      this.getLastSeed = 0,
      this.generate = 0,
      this.saveStyle = 0,
      this.getTXT2IMGHistory = 0,
      this.getInterrogators = 0,
      this.getImageTaggers = 0,
      this.deleteFile = 0,
      this.switchSDModel = 0,});

  Cmd.fromJson(dynamic json) {
    refreshModel = json['refreshModel'];
    cleanSeed = json['cleanSeed'];
    setX = json['setX'];
    getLastSeed = json['getLastSeed'];
    generate = json['generate'];
    saveStyle = json['saveStyle'];
    getTXT2IMGHistory = json['getTXT2IMGHistory'];
    getInterrogators = json['getInterrogators'];
    getImageTaggers = json['getImageTaggers'];
    deleteFile = json['deleteFile'];
    switchSDModel = json['switchSDModel'];
  }
  int refreshModel = 0;
  int cleanSeed = 0;
  int setX = 0;
  int getLastSeed = 0;
  int generate = 0;
  int saveStyle = 0;
  int getTXT2IMGHistory = 0;
  int getInterrogators = 0;
  int getImageTaggers = 0;
  int deleteFile = 0;
  int switchSDModel = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['refreshModel'] = refreshModel;
    map['cleanSeed'] = cleanSeed;
    map['setX'] = setX;
    map['getLastSeed'] = getLastSeed;
    map['generate'] = generate;
    map['saveStyle'] = saveStyle;
    map['getTXT2IMGHistory'] = getTXT2IMGHistory;
    map['getInterrogators'] = getInterrogators;
    map['getImageTaggers'] = getImageTaggers;
    map['deleteFile'] = deleteFile;
    map['switchSDModel'] = switchSDModel;
    return map;
  }


  get CMD_ADD_TO_FAVOURITE => deleteFile + 2;

  get CMD_GET_MORE_HISTORY => getTXT2IMGHistory + 88;

  get CMD_FAVOURITE_HISTORY => getTXT2IMGHistory + 109;

  get CMD_SET_Y => setX + 1;

  get CMD_SET_Z => setX + 2;

  get CMD_REFRESH_STYLE => refreshModel + 6;

  get CMD_GET_LAST_PROMPT => refreshModel + 9; //9

}