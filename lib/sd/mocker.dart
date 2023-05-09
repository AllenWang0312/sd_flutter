const TAG_MY_TAGS = '/file=extensions/sd_flutter/tags';

const TAG_COMPUTE = '/file=extensions/tagcomplete/tags';

const TAG_COMPUTE_CN = '$TAG_COMPUTE/zh_cn.csv';

const FILE_TEMP_PATH = "/file=extensions/tagcomplete/tags/temp";



const CMD_REFRESH_MODEL = 0;

const CMD_REFRESH_STYLE = CMD_REFRESH_MODEL + 6;

const CMD_GET_LAST_PROMPT = CMD_REFRESH_MODEL + 9; //9

const CMD_CLEAN_SEED = 126;

const CMD_MULTI_GENERAGE = 244;
// const options = [
//   'Nothing',
//   'Seed',
//   'Var. seed',
//   'Var. strength',
//   'Steps',
//   'Hires steps',
//   'CFG Scale',
//   'Prompt S/R',
//   'Prompt order',
//   'Sampler',
//   'Sampler',
//   'Checkpoint name',
//   'Sigma Churn',
//   'Sigma min',
//   'Sigma max',
//   'Sigma noise',
//   'Eta',
//   'Clip skip',
//   'Denoising',
//   'Hires upscaler',
//   'Cond. Image Mask Weight',
//   'VAE',
//   'Styles'
// ];
const CMD_SET_X = 262;

const CMD_SET_Y = CMD_SET_X + 1;

const CMD_SET_Z = CMD_SET_X + 2;

const CMD_SINGLE_GENERAGE = 291;

const CMD_GET_LAST_SEED = 288;

const CMD_SAVE_STYLE = 499;

const CMD_GET_INTERROGATORS = 704;

const CMD_IMG_TAGGER = 708;


// const CMD_GET_IMG2IMG_HISTORY = CMD_GET_TXT2IMG_HISTORY+22;
//
// const CMD_GET_TXT2IMG_GRID_HISTORY = CMD_GET_TXT2IMG_HISTORY+34;
//
// const CMD_GET_IMG2IMG_GRID_HISTORY = CMD_GET_TXT2IMG_HISTORY+66;

const CMD_DELETE_FILE = 741;

const CMD_ADD_TO_FAVOURITE = CMD_DELETE_FILE + 2;

const CMD_GET_TXT2IMG_HISTORY = 686;

const CMD_GET_MORE_HISTORY = CMD_GET_TXT2IMG_HISTORY + 88;

const CMD_FAVOURITE_HISTORY = CMD_GET_TXT2IMG_HISTORY + 109;

const CMD_SWITCH_SD_MODEL = 853;

// const CMD_GET_ALL_SETTING = 1008;
// const CMD_GET_CONFIGS = CMD_GET_ALL_SETTING + 12;

const BASE64_PREFIX = 'data:image/png;base64,';


dynamic multiGenerateBody(dynamic data, int pi, int times) {
  return {
    "fn_index": CMD_SINGLE_GENERAGE,
    "data": [
      "", //task(74b1tly1v240aog)
      data['prompt'],
      data['negative_prompt'],
      data['styles'], //选择的style
      data['steps'],
      data['sampler_name'],
      data['restore_faces'],
      data['tiling'],
      times,
      pi, //每批数量
      7, //cfg scale
      data['seed'], //第一张图seed 后面累加
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
      "Latent", //data['hr_upscaler'],
      0,
      0,
      0,
      [],
      "None",
      false,
      "MultiDiffusion",
      false,
      10,
      1,
      1,
      64,
      false,
      true,
      1024,
      1024,
      96,
      96,
      48,
      1,
      "None",
      2,
      false,
      false,
      false,
      false,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      0.4,
      0.4,
      0.2,
      0.2,
      "",
      "",
      "Background",
      0.2,
      -1,
      false,
      false,
      true,
      true,
      false,
      1536,
      96,
      false,
      "",
      0,
      false,
      false,
      "LoRA",
      "None",
      0,
      0,
      "LoRA",
      "None",
      0,
      0,
      "LoRA",
      "None",
      0,
      0,
      "LoRA",
      "None",
      0,
      0,
      "LoRA",
      "None",
      0,
      0,
      "Refresh models",
      null,
      false,
      "none",
      "None",
      1,
      null,
      false,
      "Scale to Fit (Inner Fit)",
      false,
      false,
      64,
      64,
      64,
      1,
      false,
      false,
      "",
      0.5,
      true,
      false,
      "",
      "Lerp",
      false,
      0.9,
      5,
      "0.0001",
      false,
      "None",
      "",
      0.1,
      false,
      false,
      false,
      "positive",
      "comma",
      0,
      false,
      false,
      "",
      "Seed",
      "",
      "Nothing",
      "",
      "Nothing",
      "",
      true,
      false,
      false,
      false,
      0,
      "Not set",
      true,
      true,
      "",
      "",
      "",
      "",
      "",
      1.3,
      "Not set",
      "Not set",
      1.3,
      "Not set",
      1.3,
      "Not set",
      1.3,
      1.3,
      "Not set",
      1.3,
      "Not set",
      1.3,
      "Not set",
      1.3,
      "Not set",
      1.3,
      "Not set",
      1.3,
      "Not set",
      false,
      "None",
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

dynamic getPreview(int id) {
  return {
    // "id_task": "task(9drtdfvly2g47gc)",
    "id_live_preview": id
  };
}

//data:image/png;base64,
dynamic tagger(String encodeData, String interrogator, double threshold) {
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
      interrogator, //interrogator 858刷新
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

dynamic setPluginCover(String remotePath, String pluginPathNoExt) {
  return {
    "fn_index": 297,
    "data": [
      -1,
      [
        {"name": remotePath, "data": "file=$remotePath", "is_file": true}
      ],
      "$pluginPathNoExt.preview.png"
    ],
    "session_hash": "m7od6wwmtql"
  };
}

dynamic getRemoteHistoryInfo(int fnIndex, int index, int page, String type) {
  return {
    "fn_index": fnIndex,
    "data": [type, "$index", page],
    // "session_hash": "ilpmq48h4ug"
  };
}

dynamic addToFavourite(int fnIndex, String remoteFilePath) {
  return {
    "fn_index": fnIndex,
    "data": [remoteFilePath],
    // "session_hash": "ilpmq48h4ug"
  };
}

dynamic delateFile(
    int fnIndex, String? filePath, int page, int index, int pageSize) {
  return {
    "fn_index": fnIndex,
    "data": [1, filePath, null, "$index", pageSize],
    // "session_hash": "cqewqfm6sps"
  };
}

dynamic getInterrogators() {
  return {
    "fn_index": CMD_GET_INTERROGATORS,
    "data": [],
    // "session_hash": "lcm8sq8kso"
  };
}

dynamic getLastPrompt() {
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

dynamic cleanSeed() {
  return {
    "fn_index": CMD_CLEAN_SEED,
    "data": [],
    // "session_hash": "xo1qqnyjm6"
  };
}

dynamic refreshModel() {
  return {
    "fn_index": CMD_REFRESH_MODEL,
    "data": [],
    // "session_hash": "xo1qqnyjm6"
  };
}

// dynamic getConfigs() {
//   return {
//     "fn_index": CMD_GET_CONFIGS,
//     "data": [],
//     // "session_hash": "7vuvdqy85iv"
//   };
// }
