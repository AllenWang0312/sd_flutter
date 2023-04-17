# StableDiffusion Flutter 


# 开发进度
## v1
[x] 单图生成
[x] 多图生成 使用run/predict 接口 fn_index 可能需要用户自行配置
[x] tagger 识别
[x] 文件头 prompt 解析
[x] 远端 styles 使用/修改

[ ] 本地workspace 创建
[ ] 本地styles 创建


workspace 默认不带 style 创建的时候可以选择从接口复制  或者从现有ws 的 styles 复制
独立创建的style 相当于是公共的 ws只是引用  修改会同步到其他引用的地方  不存到数据库  只以 /Pictures/sdf/style/目录为准  用户可以 在电脑端分类公共部分


UI 如何刷新
什么时候用 provider + stateless
* ui 依赖于数据 且数据需要跨页面共享
是么时候用 stateful
* 列表/刷新 item可以用provider
*

数据何时获取
stateless 上一个页面传入
stateful initState async 方法  可能导致build 时数据未准备好

60120A97-E297-4A4A-AC09-593E85573EB4
