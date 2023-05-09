 class Translate{


   static const TABLE_NAME = "translate_zh";
   static const Columns = ['keyWords','type','year','translate'];

   static const TABLE_CREATE = 'id INTEGER PRIMARY KEY,keyWords TEXT UNIQUE,type INTEGER,year INTEGER,translate TEXT';

   Translate.fromJson(dynamic json) {
     keyWords = json['keyWords'];
     translate = json['translate'];
     type = json['type'];
     year = json['year'];

   }
   String keyWords = '';
   String translate = '';
   int type = 0;
   int year = 0;

   Translate(this.keyWords, {this.translate = '', this.type = 0,this.year=0});

  Map<String, dynamic> toJson() {
     final map = <String, dynamic>{};
     map['keyWords'] = keyWords;
     map['translate'] = translate;
     map['type'] = type;
     map['year'] = year;

     return map;
   }






}

