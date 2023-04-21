
const CMD_GET_LAST_PROMPT = 9;
const CMD_REFRESH_STYLE = 124;
const CMD_CLEAN_SEED = 128;
const CMD_MULTI_GENERAGE =244;
const CMD_SAVE_STYLE = 499;
const CMD_GET_REMOTE_HISTORY = 504;
const CMD_DELETE_FILE = 719;
const CMD_GET_INTERROGATORS = 858;
const CMD_IMG_TAGGER = 635;
const CMD_GET_ALL_SETTING = 885;
const CMD_SWITCH_SD_MODEL = 656;
const CMD_GET_CONFIGS = 897;

const BASE64_PREFIX = 'data:image/png;base64,';

dynamic multiGenerateBody(dynamic data,int pi ,int times) {
  return {
    "fn_index": CMD_MULTI_GENERAGE,
    "data": [
      "", //task(74b1tly1v240aog)
      data['prompt'],
      data['negative_prompt'],
      [],
      data['steps'],
      data['sampler_name'],
      data['restore_faces'],
      data['tiling'],
      pi,
      times,//每批数量
      7,//cfg scale
      data['seed'],//第一张图seed 后面累加
      -1,
      0,
      0,
      0,
      false,
      data['firstphase_height'],
      data['firstphase_width'],
      true,
      0.3,
      2,
      "Latent",
      0,
      0,
      0,
      [],
      "None",//脚本 X/Y/Z plot
      false,
      "MultiDiffusion",
      false,
      true,
      1024,
      1024,
      64,
      64,
      32,
      1,
      "None",
      2,
      false,
      false,
      1,
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      1,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      false,
      false,
      true,
      true,
      0,
      1536,
      96,
      false,
      "",
      0,
      null,
      false,
      false,
      "positive",
      "comma",
      0,
      false,
      false,
      "",
      "Seed",//Checkpoint name
      "",//args
      "Nothing",
      "",
      "Nothing",
      "",
      true,
      false,
      false,
      false,
      0,
      null,
      false,
      50,
      [],
      "",
      "",
      ""
    ],
    // "session_hash": "pi2wtd3ckx8"
  };
}
dynamic getPreview(int id){
  return {
    // "id_task": "task(9drtdfvly2g47gc)",
    "id_live_preview": id
  };
}
//data:image/png;base64,
dynamic tagger(String encodeData,double threshold){
  return {
    "fn_index": CMD_IMG_TAGGER,
    "data": [
      "$BASE64_PREFIX$encodeData",
      "",
      false,
      "",
      "[name].[output_extension]",
      "ignore",
      false,
      false,
      "wd14-vit-v2-git",//interrogator 858刷新
      threshold,
      "",
      "",
      false,
      false,
      true,
      "0_0, (o)_(o), +_+, +_-, ._., <o>_<o>, <|>_<|>, =_=, >_<, 3_3, 6_9, >_o, @_@, ^_^, o_o, u_u, x_x, |_|, ||_||",
      false,
      false
    ],
    // "session_hash": "q1t6lahrvf"
  };
}



dynamic delateFile(String filePath,int page,int index){
  return {
    "fn_index": CMD_DELETE_FILE,
    "data": [
      page,
      filePath,
      null,
      "$index",
      36
    ],
    // "session_hash": "cqewqfm6sps"
  };
}
dynamic getInterrogators(){
  return {
    "fn_index": CMD_GET_INTERROGATORS,
    "data": [],
    // "session_hash": "lcm8sq8kso"
  };
}
dynamic getLastPrompt(){
  return {
    "fn_index": CMD_GET_LAST_PROMPT,
    "data": [
      "",
      "",
      "",
      20,
      "Euler a",
      false,
      7,
      -1,
      512,
      512,
      1,
      -1,
      0,
      0,
      0,
      0.7,
      false,
      null,
      2,
      "Latent",
      0,
      0,
      0,
      false,
      false,
      "LoRA",
      "None",
      1,
      1,
      1,
      "LoRA",
      "None",
      1,
      1,
      1,
      "LoRA",
      "None",
      1,
      1,
      1,
      "LoRA",
      "None",
      1,
      1,
      1,
      "LoRA",
      "None",
      1,
      1,
      1,
      false,
      "none",
      "None",
      1,
      0,
      1,
      "0.0001",
      0.9,
      5,
      "None",
      false,
      "",
      false,
      0.1,
      "Seed",
      "",
      "Nothing",
      "",
      "Nothing",
      "",
      "None",
      null,
      null,
      null,
      null,
      null,
      []
    ],
    // "session_hash": "b2810whwrvs"
  };
}
dynamic cleanSeed(){
  return {
    "fn_index": CMD_CLEAN_SEED,
    "data": [],
    // "session_hash": "xo1qqnyjm6"
  };
}
dynamic getConfigs(){
  return {
    "fn_index": CMD_GET_CONFIGS,
    "data": [],
    // "session_hash": "7vuvdqy85iv"
  };
}

