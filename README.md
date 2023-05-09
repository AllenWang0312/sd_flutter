# StableDiffusion Flutter 
移动端技术方案

高性能 jni + c++  c# c++
纯原生语言  java c#
新语言 kotlin swift
新架构 compose swiftui
跨平台架构 Flutter ReactNative;

# 开发进度

## 接口功能对齐
* [ ] 初次启动sd 不选择模型 没有spainer 给用户选择 需要实现刷新接口 (封装到内部sateful)
* [ ] 找到调用的统一方法 或 fn_index 生成规则
* [x] 单图生成
* [x] 多图生成 使用run/predict 接口 fn_index 可能需要用户clone自行配置
* [x] tagger 识别
* [x] 文件头 prompt 解析
* [x] 远端 styles 使用/修改
* [x] styles 支持分步执行
  * 需要在 extensions/sd_flutter/tags 下 放置3个配置csv
    0.csv 表示内部配置不分步执行 始终存在
    1.csv  表示内部配置分步1 执行
    2.csv  表示内部配置分步2 执行
  * 上述文件支持配置分组 层级需要用| 间隔
  * 配置命 后* 表示该项在同级目录下 单选 同级互斥
[//]: # (  * 配置命 后^ 表示该项在同级目录下 单选)
* [x] 本地workspace 创建 设置style
* [x] 本地styles 创建/拆分/预览

## v1 面向android开发者
* [x] 自动解析Download 下图片 以及 Download/sdf 下的图片
* [ ] 50% Download/sdf下的文件夹如果存在对应网站 则在主页为其生成特定文件夹
* [ ] 特定文件夹默认打开方式设置
* [x] 内置浏览器 分级下载
* [x] 文件可见性问题
        Download 目录下无法 通过 nomedia 屏蔽目录



## v2 面向github开发者
* [ ] fn_index 可能需要用户在设置里指向自己的配置文件

## v2.5 多模式适配
* [ ] 横竖屏适配

## v3 多平台适配
* [ ] 参考google相册web版 适配
    * [x] 简单布局适配
    * [ ] remote history grid 适配
    * [ ] setting list 适配
    * [x] 调研 google手机横屏
    * [ ] 手机系统不会变更系统层级


数据类型
1. 平台差异化配置 需要splash 异步生成 保存在内存字段中;
2. sp 配置
3. db 配置 本地年龄限制 记录  // workspace  style
4. 网络数据 图片 视屏等
5. 本地数据 图片 prompt.txt 网站启动方式/个性化配置等


