const String DEFAULT_SAMPLER = "Euler a";
const String DEFAULT_UPSCALE = "None";

const int DEFAULT_WIDTH = 512;
const int DEFAULT_HEIGHT = 768;

const String DEFAULT_WORKSPACE_NAME = "default";
const int DEFAULT_SAMPLER_STEPS = 30;
const bool DEFAULT_FACE_FIX = false;
const bool DEFAULT_HIRES_FIX = false;
const bool DEFAULT_AUTO_SAVE = false;
const bool DEFAULT_HIDE_NSFW = true;
const bool DEFAULT_CHECK_IDENTITY = false;

const String NOTHING = "Nothing";
// const String SEED = "Seed";
// const String VAR_SEED = "Var. seed";
const String STESPS = "Steps";
const String PROMPT_SR = "Prompt S/R";
const String SAMPLER = "Sampler";

const String CHECKPOINT_NAME = "Checkpoint name";
const String VAE = "VAE";
const Promptable = [false, false, false, true, true, true];
const XYZKeys = ['无', "迭代步数", "提示词替换", "采样器", "模型(ckpt)名", "VAE"];
const XYZValues = [NOTHING, STESPS, PROMPT_SR, SAMPLER, CHECKPOINT_NAME, VAE];
