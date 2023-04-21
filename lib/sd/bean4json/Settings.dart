class Settings {
  Settings({
      this.samplesSave, 
      this.samplesFormat, 
      this.samplesFilenamePattern, 
      this.saveImagesAddNumber, 
      this.gridSave, 
      this.gridFormat, 
      this.gridExtendedFilename, 
      this.gridOnlyIfMultiple, 
      this.gridPreventEmptySpots, 
      this.nRows, 
      this.enablePnginfo, 
      this.saveTxt, 
      this.saveImagesBeforeFaceRestoration, 
      this.saveImagesBeforeHighresFix, 
      this.saveImagesBeforeColorCorrection, 
      this.jpegQuality, 
      this.exportFor4chan, 
      this.imgDownscaleThreshold, 
      this.targetSideLength, 
      this.useOriginalNameBatch, 
      this.useUpscalerNameAsSuffix, 
      this.saveSelectedOnly, 
      this.doNotAddWatermark, 
      this.tempDir, 
      this.cleanTempDirAtStart, 
      this.outdirSamples, 
      this.outdirTxt2imgSamples, 
      this.outdirImg2imgSamples, 
      this.outdirExtrasSamples, 
      this.outdirGrids, 
      this.outdirTxt2imgGrids, 
      this.outdirImg2imgGrids, 
      this.outdirSave, 
      this.saveToDirs, 
      this.gridSaveToDirs, 
      this.useSaveToDirsForUi, 
      this.directoriesFilenamePattern, 
      this.directoriesMaxPromptWords, 
      this.eSRGANTile, 
      this.eSRGANTileOverlap, 
      this.realesrganEnabledModels, 
      this.upscalerForImg2img, 
      this.faceRestorationModel, 
      this.codeFormerWeight, 
      this.faceRestorationUnload, 
      this.showWarnings, 
      this.memmonPollRate, 
      this.samplesLogStdout, 
      this.multipleTqdm, 
      this.printHypernetExtra, 
      this.unloadModelsWhenTraining, 
      this.pinMemory, 
      this.saveOptimizerState, 
      this.saveTrainingSettingsToTxt, 
      this.datasetFilenameWordRegex, 
      this.datasetFilenameJoinString, 
      this.trainingImageRepeatsPerEpoch, 
      this.trainingWriteCsvEvery, 
      this.trainingXattentionOptimizations, 
      this.trainingEnableTensorboard, 
      this.trainingTensorboardSaveImages, 
      this.trainingTensorboardFlushEvery, 
      this.sdModelCheckpoint, 
      this.sdCheckpointCache, 
      this.sdVaeCheckpointCache, 
      this.sdVae, 
      this.sdVaeAsDefault, 
      this.inpaintingMaskWeight, 
      this.initialNoiseMultiplier, 
      this.img2imgColorCorrection, 
      this.img2imgFixSteps, 
      this.img2imgBackgroundColor, 
      this.enableQuantization, 
      this.enableEmphasis, 
      this.enableBatchSeeds, 
      this.commaPaddingBacktrack, 
      this.cLIPStopAtLastLayers, 
      this.upcastAttn, 
      this.useOldEmphasisImplementation, 
      this.useOldKarrasSchedulerSigmas, 
      this.noDpmppSdeBatchDeterminism, 
      this.useOldHiresFixWidthHeight, 
      this.interrogateKeepModelsInMemory, 
      this.interrogateReturnRanks, 
      this.interrogateClipNumBeams, 
      this.interrogateClipMinLength, 
      this.interrogateClipMaxLength, 
      this.interrogateClipDictLimit, 
      // this.interrogateClipSkipCategories,
      this.interrogateDeepbooruScoreThreshold, 
      this.deepbooruSortAlpha, 
      this.deepbooruUseSpaces, 
      this.deepbooruEscape, 
      this.deepbooruFilterTags, 
      this.extraNetworksDefaultView, 
      this.extraNetworksDefaultMultiplier, 
      this.sdHypernetwork, 
      this.returnGrid, 
      this.doNotShowImages, 
      this.addModelHashToInfo, 
      this.addModelNameToInfo, 
      this.disableWeightsAutoSwap, 
      this.sendSeed, 
      this.sendSize, 
      this.font, 
      this.jsModalLightbox, 
      this.jsModalLightboxInitiallyZoomed, 
      this.showProgressInTitle, 
      this.samplersInDropdown, 
      this.dimensionsAndBatchTogether, 
      this.keyeditPrecisionAttention, 
      this.keyeditPrecisionExtra, 
      this.quicksettings, 
      this.uiReorder, 
      this.uiExtraNetworksTabReorder, 
      this.localization, 
      this.showProgressbar, 
      this.livePreviewsEnable, 
      this.showProgressGrid, 
      this.showProgressEveryNSteps, 
      this.showProgressType, 
      this.livePreviewContent, 
      this.livePreviewRefreshPeriod, 
      // this.hideSamplers,
      this.etaDdim, 
      this.etaAncestral, 
      this.ddimDiscretize, 
      this.sChurn, 
      this.sTmin, 
      this.sNoise, 
      this.etaNoiseSeedDelta, 
      this.alwaysDiscardNextToLastSigma, 
      // this.postprocessingEnableInMainUi,
      // this.postprocessingOperationOrder,
      this.upscalingMaxImagesInCache, 
      // this.disabledExtensions,
      this.sdCheckpointHash, 
      this.sdLora, 
      this.loraApplyToOutputs,});

  Settings.fromJson(dynamic json) {
    samplesSave = json['samples_save'];
    samplesFormat = json['samples_format'];
    samplesFilenamePattern = json['samples_filename_pattern'];
    saveImagesAddNumber = json['save_images_add_number'];
    gridSave = json['grid_save'];
    gridFormat = json['grid_format'];
    gridExtendedFilename = json['grid_extended_filename'];
    gridOnlyIfMultiple = json['grid_only_if_multiple'];
    gridPreventEmptySpots = json['grid_prevent_empty_spots'];
    nRows = json['n_rows'];
    enablePnginfo = json['enable_pnginfo'];
    saveTxt = json['save_txt'];
    saveImagesBeforeFaceRestoration = json['save_images_before_face_restoration'];
    saveImagesBeforeHighresFix = json['save_images_before_highres_fix'];
    saveImagesBeforeColorCorrection = json['save_images_before_color_correction'];
    jpegQuality = json['jpeg_quality'];
    exportFor4chan = json['export_for_4chan'];
    imgDownscaleThreshold = json['img_downscale_threshold'];
    targetSideLength = json['target_side_length'];
    useOriginalNameBatch = json['use_original_name_batch'];
    useUpscalerNameAsSuffix = json['use_upscaler_name_as_suffix'];
    saveSelectedOnly = json['save_selected_only'];
    doNotAddWatermark = json['do_not_add_watermark'];
    tempDir = json['temp_dir'];
    cleanTempDirAtStart = json['clean_temp_dir_at_start'];
    outdirSamples = json['outdir_samples'];
    outdirTxt2imgSamples = json['outdir_txt2img_samples'];
    outdirImg2imgSamples = json['outdir_img2img_samples'];
    outdirExtrasSamples = json['outdir_extras_samples'];
    outdirGrids = json['outdir_grids'];
    outdirTxt2imgGrids = json['outdir_txt2img_grids'];
    outdirImg2imgGrids = json['outdir_img2img_grids'];
    outdirSave = json['outdir_save'];
    saveToDirs = json['save_to_dirs'];
    gridSaveToDirs = json['grid_save_to_dirs'];
    useSaveToDirsForUi = json['use_save_to_dirs_for_ui'];
    directoriesFilenamePattern = json['directories_filename_pattern'];
    directoriesMaxPromptWords = json['directories_max_prompt_words'];
    eSRGANTile = json['ESRGAN_tile'];
    eSRGANTileOverlap = json['ESRGAN_tile_overlap'];
    realesrganEnabledModels = json['realesrgan_enabled_models'] != null ? json['realesrgan_enabled_models'].cast<String>() : [];
    upscalerForImg2img = json['upscaler_for_img2img'];
    faceRestorationModel = json['face_restoration_model'];
    codeFormerWeight = json['code_former_weight'];
    faceRestorationUnload = json['face_restoration_unload'];
    showWarnings = json['show_warnings'];
    memmonPollRate = json['memmon_poll_rate'];
    samplesLogStdout = json['samples_log_stdout'];
    multipleTqdm = json['multiple_tqdm'];
    printHypernetExtra = json['print_hypernet_extra'];
    unloadModelsWhenTraining = json['unload_models_when_training'];
    pinMemory = json['pin_memory'];
    saveOptimizerState = json['save_optimizer_state'];
    saveTrainingSettingsToTxt = json['save_training_settings_to_txt'];
    datasetFilenameWordRegex = json['dataset_filename_word_regex'];
    datasetFilenameJoinString = json['dataset_filename_join_string'];
    trainingImageRepeatsPerEpoch = json['training_image_repeats_per_epoch'];
    trainingWriteCsvEvery = json['training_write_csv_every'];
    trainingXattentionOptimizations = json['training_xattention_optimizations'];
    trainingEnableTensorboard = json['training_enable_tensorboard'];
    trainingTensorboardSaveImages = json['training_tensorboard_save_images'];
    trainingTensorboardFlushEvery = json['training_tensorboard_flush_every'];
    sdModelCheckpoint = json['sd_model_checkpoint'];
    sdCheckpointCache = json['sd_checkpoint_cache'];
    sdVaeCheckpointCache = json['sd_vae_checkpoint_cache'];
    sdVae = json['sd_vae'];
    sdVaeAsDefault = json['sd_vae_as_default'];
    inpaintingMaskWeight = json['inpainting_mask_weight'];
    initialNoiseMultiplier = json['initial_noise_multiplier'];
    img2imgColorCorrection = json['img2img_color_correction'];
    img2imgFixSteps = json['img2img_fix_steps'];
    img2imgBackgroundColor = json['img2img_background_color'];
    enableQuantization = json['enable_quantization'];
    enableEmphasis = json['enable_emphasis'];
    enableBatchSeeds = json['enable_batch_seeds'];
    commaPaddingBacktrack = json['comma_padding_backtrack'];
    cLIPStopAtLastLayers = json['CLIP_stop_at_last_layers'];
    upcastAttn = json['upcast_attn'];
    useOldEmphasisImplementation = json['use_old_emphasis_implementation'];
    useOldKarrasSchedulerSigmas = json['use_old_karras_scheduler_sigmas'];
    noDpmppSdeBatchDeterminism = json['no_dpmpp_sde_batch_determinism'];
    useOldHiresFixWidthHeight = json['use_old_hires_fix_width_height'];
    interrogateKeepModelsInMemory = json['interrogate_keep_models_in_memory'];
    interrogateReturnRanks = json['interrogate_return_ranks'];
    interrogateClipNumBeams = json['interrogate_clip_num_beams'];
    interrogateClipMinLength = json['interrogate_clip_min_length'];
    interrogateClipMaxLength = json['interrogate_clip_max_length'];
    interrogateClipDictLimit = json['interrogate_clip_dict_limit'];
    // if (json['interrogate_clip_skip_categories'] != null) {
    //   interrogateClipSkipCategories = [];
    //   json['interrogate_clip_skip_categories'].forEach((v) {
    //     interrogateClipSkipCategories.add(Dynamic.fromJson(v));
    //   });
    // }
    interrogateDeepbooruScoreThreshold = json['interrogate_deepbooru_score_threshold'];
    deepbooruSortAlpha = json['deepbooru_sort_alpha'];
    deepbooruUseSpaces = json['deepbooru_use_spaces'];
    deepbooruEscape = json['deepbooru_escape'];
    deepbooruFilterTags = json['deepbooru_filter_tags'];
    extraNetworksDefaultView = json['extra_networks_default_view'];
    extraNetworksDefaultMultiplier = json['extra_networks_default_multiplier'];
    sdHypernetwork = json['sd_hypernetwork'];
    returnGrid = json['return_grid'];
    doNotShowImages = json['do_not_show_images'];
    addModelHashToInfo = json['add_model_hash_to_info'];
    addModelNameToInfo = json['add_model_name_to_info'];
    disableWeightsAutoSwap = json['disable_weights_auto_swap'];
    sendSeed = json['send_seed'];
    sendSize = json['send_size'];
    font = json['font'];
    jsModalLightbox = json['js_modal_lightbox'];
    jsModalLightboxInitiallyZoomed = json['js_modal_lightbox_initially_zoomed'];
    showProgressInTitle = json['show_progress_in_title'];
    samplersInDropdown = json['samplers_in_dropdown'];
    dimensionsAndBatchTogether = json['dimensions_and_batch_together'];
    keyeditPrecisionAttention = json['keyedit_precision_attention'];
    keyeditPrecisionExtra = json['keyedit_precision_extra'];
    quicksettings = json['quicksettings'];
    uiReorder = json['ui_reorder'];
    uiExtraNetworksTabReorder = json['ui_extra_networks_tab_reorder'];
    localization = json['localization'];
    showProgressbar = json['show_progressbar'];
    livePreviewsEnable = json['live_previews_enable'];
    showProgressGrid = json['show_progress_grid'];
    showProgressEveryNSteps = json['show_progress_every_n_steps'];
    showProgressType = json['show_progress_type'];
    livePreviewContent = json['live_preview_content'];
    livePreviewRefreshPeriod = json['live_preview_refresh_period'];
    // if (json['hide_samplers'] != null) {
    //   hideSamplers = [];
    //   json['hide_samplers'].forEach((v) {
    //     hideSamplers.add(Dynamic.fromJson(v));
    //   });
    // }
    etaDdim = json['eta_ddim'];
    etaAncestral = json['eta_ancestral'];
    ddimDiscretize = json['ddim_discretize'];
    sChurn = json['s_churn'];
    sTmin = json['s_tmin'];
    sNoise = json['s_noise'];
    etaNoiseSeedDelta = json['eta_noise_seed_delta'];
    alwaysDiscardNextToLastSigma = json['always_discard_next_to_last_sigma'];
    // if (json['postprocessing_enable_in_main_ui'] != null) {
    //   postprocessingEnableInMainUi = [];
    //   json['postprocessing_enable_in_main_ui'].forEach((v) {
    //     postprocessingEnableInMainUi.add(Dynamic.fromJson(v));
    //   });
    // }
    // if (json['postprocessing_operation_order'] != null) {
    //   postprocessingOperationOrder = [];
    //   json['postprocessing_operation_order'].forEach((v) {
    //     postprocessingOperationOrder.add(Dynamic.fromJson(v));
    //   });
    // }
    upscalingMaxImagesInCache = json['upscaling_max_images_in_cache'];
    // if (json['disabled_extensions'] != null) {
    //   disabledExtensions = [];
    //   json['disabled_extensions'].forEach((v) {
    //     disabledExtensions.add(Dynamic.fromJson(v));
    //   });
    // }
    sdCheckpointHash = json['sd_checkpoint_hash'];
    sdLora = json['sd_lora'];
    loraApplyToOutputs = json['lora_apply_to_outputs'];
  }
  bool? samplesSave;
  String? samplesFormat;
  String? samplesFilenamePattern;
  bool? saveImagesAddNumber;
  bool? gridSave;
  String? gridFormat;
  bool? gridExtendedFilename;
  bool? gridOnlyIfMultiple;
  bool? gridPreventEmptySpots;
  double? nRows;
  bool? enablePnginfo;
  bool? saveTxt;
  bool? saveImagesBeforeFaceRestoration;
  bool? saveImagesBeforeHighresFix;
  bool? saveImagesBeforeColorCorrection;
  double? jpegQuality;
  bool? exportFor4chan;
  double? imgDownscaleThreshold;
  double? targetSideLength;
  bool? useOriginalNameBatch;
  bool? useUpscalerNameAsSuffix;
  bool? saveSelectedOnly;
  bool? doNotAddWatermark;
  String? tempDir;
  bool? cleanTempDirAtStart;
  String? outdirSamples;
  String? outdirTxt2imgSamples;
  String? outdirImg2imgSamples;
  String? outdirExtrasSamples;
  String? outdirGrids;
  String? outdirTxt2imgGrids;
  String? outdirImg2imgGrids;
  String? outdirSave;
  bool? saveToDirs;
  bool? gridSaveToDirs;
  bool? useSaveToDirsForUi;
  String? directoriesFilenamePattern;
  double? directoriesMaxPromptWords;
  double? eSRGANTile;
  double? eSRGANTileOverlap;
  List<String>? realesrganEnabledModels;
  dynamic upscalerForImg2img;
  String? faceRestorationModel;
  double? codeFormerWeight;
  bool? faceRestorationUnload;
  bool? showWarnings;
  double? memmonPollRate;
  bool? samplesLogStdout;
  bool? multipleTqdm;
  bool? printHypernetExtra;
  bool? unloadModelsWhenTraining;
  bool? pinMemory;
  bool? saveOptimizerState;
  bool? saveTrainingSettingsToTxt;
  String? datasetFilenameWordRegex;
  String? datasetFilenameJoinString;
  double? trainingImageRepeatsPerEpoch;
  double? trainingWriteCsvEvery;
  bool? trainingXattentionOptimizations;
  bool? trainingEnableTensorboard;
  bool? trainingTensorboardSaveImages;
  double? trainingTensorboardFlushEvery;
  String? sdModelCheckpoint;
  double? sdCheckpointCache;
  double? sdVaeCheckpointCache;
  String? sdVae;
  bool? sdVaeAsDefault;
  int? inpaintingMaskWeight;
  int? initialNoiseMultiplier;
  bool? img2imgColorCorrection;
  bool? img2imgFixSteps;
  String? img2imgBackgroundColor;
  bool? enableQuantization;
  bool? enableEmphasis;
  bool? enableBatchSeeds;
  double? commaPaddingBacktrack;
  double? cLIPStopAtLastLayers;
  bool? upcastAttn;
  bool? useOldEmphasisImplementation;
  bool? useOldKarrasSchedulerSigmas;
  bool? noDpmppSdeBatchDeterminism;
  bool? useOldHiresFixWidthHeight;
  bool? interrogateKeepModelsInMemory;
  bool? interrogateReturnRanks;
  double? interrogateClipNumBeams;
  double? interrogateClipMinLength;
  double? interrogateClipMaxLength;
  double? interrogateClipDictLimit;
  // List<dynamic>? interrogateClipSkipCategories;
  double? interrogateDeepbooruScoreThreshold;
  bool? deepbooruSortAlpha;
  bool? deepbooruUseSpaces;
  bool? deepbooruEscape;
  String? deepbooruFilterTags;
  String? extraNetworksDefaultView;
  int? extraNetworksDefaultMultiplier;
  String? sdHypernetwork;
  bool? returnGrid;
  bool? doNotShowImages;
  bool? addModelHashToInfo;
  bool? addModelNameToInfo;
  bool? disableWeightsAutoSwap;
  bool? sendSeed;
  bool? sendSize;
  String? font;
  bool? jsModalLightbox;
  bool? jsModalLightboxInitiallyZoomed;
  bool? showProgressInTitle;
  bool? samplersInDropdown;
  bool? dimensionsAndBatchTogether;
  double? keyeditPrecisionAttention;
  double? keyeditPrecisionExtra;
  String? quicksettings;
  String? uiReorder;
  String? uiExtraNetworksTabReorder;
  String? localization;
  bool? showProgressbar;
  bool? livePreviewsEnable;
  bool? showProgressGrid;
  double? showProgressEveryNSteps;
  String? showProgressType;
  String? livePreviewContent;
  double? livePreviewRefreshPeriod;
  // List<dynamic>? hideSamplers;
  int? etaDdim;
  int? etaAncestral;
  String? ddimDiscretize;
  int? sChurn;
  int? sTmin;
  int? sNoise;
  double? etaNoiseSeedDelta;
  bool? alwaysDiscardNextToLastSigma;
  // List<dynamic>? postprocessingEnableInMainUi;
  // List<dynamic>? postprocessingOperationOrder;
  double? upscalingMaxImagesInCache;
  // List<dynamic>? disabledExtensions;
  String? sdCheckpointHash;
  String? sdLora;
  bool? loraApplyToOutputs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['samples_save'] = samplesSave;
    map['samples_format'] = samplesFormat;
    map['samples_filename_pattern'] = samplesFilenamePattern;
    map['save_images_add_number'] = saveImagesAddNumber;
    map['grid_save'] = gridSave;
    map['grid_format'] = gridFormat;
    map['grid_extended_filename'] = gridExtendedFilename;
    map['grid_only_if_multiple'] = gridOnlyIfMultiple;
    map['grid_prevent_empty_spots'] = gridPreventEmptySpots;
    map['n_rows'] = nRows;
    map['enable_pnginfo'] = enablePnginfo;
    map['save_txt'] = saveTxt;
    map['save_images_before_face_restoration'] = saveImagesBeforeFaceRestoration;
    map['save_images_before_highres_fix'] = saveImagesBeforeHighresFix;
    map['save_images_before_color_correction'] = saveImagesBeforeColorCorrection;
    map['jpeg_quality'] = jpegQuality;
    map['export_for_4chan'] = exportFor4chan;
    map['img_downscale_threshold'] = imgDownscaleThreshold;
    map['target_side_length'] = targetSideLength;
    map['use_original_name_batch'] = useOriginalNameBatch;
    map['use_upscaler_name_as_suffix'] = useUpscalerNameAsSuffix;
    map['save_selected_only'] = saveSelectedOnly;
    map['do_not_add_watermark'] = doNotAddWatermark;
    map['temp_dir'] = tempDir;
    map['clean_temp_dir_at_start'] = cleanTempDirAtStart;
    map['outdir_samples'] = outdirSamples;
    map['outdir_txt2img_samples'] = outdirTxt2imgSamples;
    map['outdir_img2img_samples'] = outdirImg2imgSamples;
    map['outdir_extras_samples'] = outdirExtrasSamples;
    map['outdir_grids'] = outdirGrids;
    map['outdir_txt2img_grids'] = outdirTxt2imgGrids;
    map['outdir_img2img_grids'] = outdirImg2imgGrids;
    map['outdir_save'] = outdirSave;
    map['save_to_dirs'] = saveToDirs;
    map['grid_save_to_dirs'] = gridSaveToDirs;
    map['use_save_to_dirs_for_ui'] = useSaveToDirsForUi;
    map['directories_filename_pattern'] = directoriesFilenamePattern;
    map['directories_max_prompt_words'] = directoriesMaxPromptWords;
    map['ESRGAN_tile'] = eSRGANTile;
    map['ESRGAN_tile_overlap'] = eSRGANTileOverlap;
    map['realesrgan_enabled_models'] = realesrganEnabledModels;
    map['upscaler_for_img2img'] = upscalerForImg2img;
    map['face_restoration_model'] = faceRestorationModel;
    map['code_former_weight'] = codeFormerWeight;
    map['face_restoration_unload'] = faceRestorationUnload;
    map['show_warnings'] = showWarnings;
    map['memmon_poll_rate'] = memmonPollRate;
    map['samples_log_stdout'] = samplesLogStdout;
    map['multiple_tqdm'] = multipleTqdm;
    map['print_hypernet_extra'] = printHypernetExtra;
    map['unload_models_when_training'] = unloadModelsWhenTraining;
    map['pin_memory'] = pinMemory;
    map['save_optimizer_state'] = saveOptimizerState;
    map['save_training_settings_to_txt'] = saveTrainingSettingsToTxt;
    map['dataset_filename_word_regex'] = datasetFilenameWordRegex;
    map['dataset_filename_join_string'] = datasetFilenameJoinString;
    map['training_image_repeats_per_epoch'] = trainingImageRepeatsPerEpoch;
    map['training_write_csv_every'] = trainingWriteCsvEvery;
    map['training_xattention_optimizations'] = trainingXattentionOptimizations;
    map['training_enable_tensorboard'] = trainingEnableTensorboard;
    map['training_tensorboard_save_images'] = trainingTensorboardSaveImages;
    map['training_tensorboard_flush_every'] = trainingTensorboardFlushEvery;
    map['sd_model_checkpoint'] = sdModelCheckpoint;
    map['sd_checkpoint_cache'] = sdCheckpointCache;
    map['sd_vae_checkpoint_cache'] = sdVaeCheckpointCache;
    map['sd_vae'] = sdVae;
    map['sd_vae_as_default'] = sdVaeAsDefault;
    map['inpainting_mask_weight'] = inpaintingMaskWeight;
    map['initial_noise_multiplier'] = initialNoiseMultiplier;
    map['img2img_color_correction'] = img2imgColorCorrection;
    map['img2img_fix_steps'] = img2imgFixSteps;
    map['img2img_background_color'] = img2imgBackgroundColor;
    map['enable_quantization'] = enableQuantization;
    map['enable_emphasis'] = enableEmphasis;
    map['enable_batch_seeds'] = enableBatchSeeds;
    map['comma_padding_backtrack'] = commaPaddingBacktrack;
    map['CLIP_stop_at_last_layers'] = cLIPStopAtLastLayers;
    map['upcast_attn'] = upcastAttn;
    map['use_old_emphasis_implementation'] = useOldEmphasisImplementation;
    map['use_old_karras_scheduler_sigmas'] = useOldKarrasSchedulerSigmas;
    map['no_dpmpp_sde_batch_determinism'] = noDpmppSdeBatchDeterminism;
    map['use_old_hires_fix_width_height'] = useOldHiresFixWidthHeight;
    map['interrogate_keep_models_in_memory'] = interrogateKeepModelsInMemory;
    map['interrogate_return_ranks'] = interrogateReturnRanks;
    map['interrogate_clip_num_beams'] = interrogateClipNumBeams;
    map['interrogate_clip_min_length'] = interrogateClipMinLength;
    map['interrogate_clip_max_length'] = interrogateClipMaxLength;
    map['interrogate_clip_dict_limit'] = interrogateClipDictLimit;
    // if (interrogateClipSkipCategories != null) {
    //   map['interrogate_clip_skip_categories'] = interrogateClipSkipCategories.map((v) => v.toJson()).toList();
    // }
    map['interrogate_deepbooru_score_threshold'] = interrogateDeepbooruScoreThreshold;
    map['deepbooru_sort_alpha'] = deepbooruSortAlpha;
    map['deepbooru_use_spaces'] = deepbooruUseSpaces;
    map['deepbooru_escape'] = deepbooruEscape;
    map['deepbooru_filter_tags'] = deepbooruFilterTags;
    map['extra_networks_default_view'] = extraNetworksDefaultView;
    map['extra_networks_default_multiplier'] = extraNetworksDefaultMultiplier;
    map['sd_hypernetwork'] = sdHypernetwork;
    map['return_grid'] = returnGrid;
    map['do_not_show_images'] = doNotShowImages;
    map['add_model_hash_to_info'] = addModelHashToInfo;
    map['add_model_name_to_info'] = addModelNameToInfo;
    map['disable_weights_auto_swap'] = disableWeightsAutoSwap;
    map['send_seed'] = sendSeed;
    map['send_size'] = sendSize;
    map['font'] = font;
    map['js_modal_lightbox'] = jsModalLightbox;
    map['js_modal_lightbox_initially_zoomed'] = jsModalLightboxInitiallyZoomed;
    map['show_progress_in_title'] = showProgressInTitle;
    map['samplers_in_dropdown'] = samplersInDropdown;
    map['dimensions_and_batch_together'] = dimensionsAndBatchTogether;
    map['keyedit_precision_attention'] = keyeditPrecisionAttention;
    map['keyedit_precision_extra'] = keyeditPrecisionExtra;
    map['quicksettings'] = quicksettings;
    map['ui_reorder'] = uiReorder;
    map['ui_extra_networks_tab_reorder'] = uiExtraNetworksTabReorder;
    map['localization'] = localization;
    map['show_progressbar'] = showProgressbar;
    map['live_previews_enable'] = livePreviewsEnable;
    map['show_progress_grid'] = showProgressGrid;
    map['show_progress_every_n_steps'] = showProgressEveryNSteps;
    map['show_progress_type'] = showProgressType;
    map['live_preview_content'] = livePreviewContent;
    map['live_preview_refresh_period'] = livePreviewRefreshPeriod;
    // if (hideSamplers != null) {
    //   map['hide_samplers'] = hideSamplers.map((v) => v.toJson()).toList();
    // }
    map['eta_ddim'] = etaDdim;
    map['eta_ancestral'] = etaAncestral;
    map['ddim_discretize'] = ddimDiscretize;
    map['s_churn'] = sChurn;
    map['s_tmin'] = sTmin;
    map['s_noise'] = sNoise;
    map['eta_noise_seed_delta'] = etaNoiseSeedDelta;
    map['always_discard_next_to_last_sigma'] = alwaysDiscardNextToLastSigma;
    // if (postprocessingEnableInMainUi != null) {
    //   map['postprocessing_enable_in_main_ui'] = postprocessingEnableInMainUi.map((v) => v.toJson()).toList();
    // }
    // if (postprocessingOperationOrder != null) {
    //   map['postprocessing_operation_order'] = postprocessingOperationOrder.map((v) => v.toJson()).toList();
    // }
    map['upscaling_max_images_in_cache'] = upscalingMaxImagesInCache;
    // if (disabledExtensions != null) {
    //   map['disabled_extensions'] = disabledExtensions.map((v) => v.toJson()).toList();
    // }
    map['sd_checkpoint_hash'] = sdCheckpointHash;
    map['sd_lora'] = sdLora;
    map['lora_apply_to_outputs'] = loraApplyToOutputs;
    return map;
  }

}