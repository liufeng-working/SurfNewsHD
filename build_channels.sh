#格式：sh ./build_channel_task.sh 渠道名称 渠道id

#clean
xcodebuild -scheme "SurfNews-JAILBREAK" -configuration Release clean

#开始各任务
sh ./build_channel_task.sh TONGBUTUI 4sBPss8V
sh ./build_channel_task.sh WEIPHONE 0S1fSSDJ
sh ./build_channel_task.sh WEIPHONE 6G0KGGsu
sh ./build_channel_task.sh 91ZHUSHOU 3luIll6g


