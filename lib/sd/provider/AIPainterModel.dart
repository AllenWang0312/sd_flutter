import 'package:sd/common/splash_page.dart';
import 'package:sd/sd/bean4json/UpScaler.dart';
import 'package:sd/sd/http_service.dart';
import 'package:sd/sd/pages/home/txt2img/NetWorkStateProvider.dart';
import 'package:sd/sd/pages/home/txt2img/tagger_widget.dart';
import 'package:sd/sd/provider/config_model.dart';
import 'package:sd/sd/provider/index_recorder.dart';



//存放需要在闪屏页初始化的配置
//todo 类瘦身 没必要常态化持有的 拆分出去

const String TAG = 'AIPainterModel';


class AIPainterModel extends ConfigModel with IndexRecorder,NetWorkStateProvider{
  int countdownNum = SPLASH_WATTING_TIME; // todo 连同timer 封装到组件  闪屏页倒计时

  String? selectedSDModel;
  String selectedInterrogator = DEFAULT_INTERROGATOR;
  List<UpScaler> upScalers = [];
  String lastGenerate = '';



  // late Map<String, ImageSize?> imgSize = {};
  // bool https = false;
  // double denoisingStrength = 0.3;
  // int resizeWidth = 0;
  // int resizeHeight = 0;
  // String selectedSDModel = "";
  // Map<String, double> checkedPlugins = Map(); // lora


  void setAgeLevel(String sign,int value) {
    if (value > 0) {
      limit.putIfAbsent(sign, () => value);
    } else {
     limit.remove(sign);
    }
    notifyListeners();
  }

  int getAgeLevel(String sign) {
    return limit[sign] ?? 0;
  }


  @override
  void updateIndex(int index) {
    this.index = index;
    notifyListeners();
  }
  @override
  void updateNetworkState(int i) {
    netWorkState = i;
    notifyListeners();
  }

  void switchCheckState(String prefix, String name) {
    if (checkedPlugins.keys.contains("$prefix:$name")) {
      checkedPlugins.remove("$prefix:$name");
      // prompt.replaceAll(getPluginMarch(prefix, name), "");
    } else {
      checkedPlugins.putIfAbsent('$prefix:$name', () => 1.0);
      // prompt+="<$prefix:$name:1.0>";
    }
    notifyListeners();
  }


  updateSDModel(String? model) {
    selectedSDModel = model;
    logt(TAG, model??"null");
    notifyListeners();
  }

  // refreshStyles(List<String> choices) {
  //   checkedStyles.forEach((element) {
  //     if (!choices.contains(element)) {
  //       checkedStyles.remove(element);
  //     }
  //   });
  //   notifyListeners();
  // }

  countDown() {
    countdownNum--;
    notifyListeners();
  }

  void selectInterrogator(newValue) {
    selectedInterrogator = newValue;
    notifyListeners();
  }



  String getCheckedPluginsString() {
    String result = "";
    for (String key in checkedPlugins.keys) {
      result += "<$key:${checkedPlugins[key]}>";
    }
    return result;
  }



  int limitedUrl(String imgUrl) {
    return limit[imgUrl] ?? 0;
  }

  void updateCheckRadio(String group, String? name) {

    if(null!=name){
      bool exit = checkedRadioGroup.contains(group);
      if(exit){
        checkedRadio[checkedRadioGroup.indexOf(group)]=name;
      }else{
        checkedRadioGroup.add(group);
        checkedRadio.add(name);
      }
    }else{
      int index = checkedRadioGroup.indexOf(group);
      checkedRadio.removeAt(index);
      checkedRadioGroup.removeAt(index);
    }
    logt(TAG,"${checkedRadioGroup.toString()} ${checkedRadio.toString()}");
    notifyListeners();
  }

  void randomCheckedStyle() {
    optional.randomChild(this);
    notifyListeners();
  }

  void unCheckRadio(String name) {
    int index = checkedRadio.indexOf(name);
    if(index>=0){
      checkedRadio.remove(name);
      checkedRadioGroup.removeAt(index);
    notifyListeners();
    }

  }


  // void updateLastGenerate(String lastGenerate){
  //   this.lastGenerate = lastGenerate;
  //
  //   notifyListeners();
  // }


}
