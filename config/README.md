# 首页配置说明

`home-items.sample.xml` 是归藏电视的首页配置文件（SharedPreferences 格式），六个入口：

| 顺序 | 包名 / 特殊 id | 显示名 |
|---|---|---|
| 1 | `com.brlf.tvlivelaunch` | 河南IPTV |
| 2 | `com.fongmi.android.tv` | OK影视 |
| 3 | `com.yunpan.appmanage` | 应用管家 |
| 4 | `tv.fix.home` | 桌面切换（本仓库的 HomeFix） |
| 5 | `com.android.settings` | 系统设置 |
| 6 | `action:shutdown` | 关机（触发待机） |

## 改成你自己的

- 包名要和电视上实际装的应用一致，否则首页会显示"暂时不可用"
- 最多 9 项
- `action:shutdown` 是特殊 id，不要删（它就是待机入口）
- 名称可以随便改，只是显示用

## 写入

```bash
adb push home-items.sample.xml /data/local/tmp/home-items.xml
adb shell run-as io.github.op7418.guizangtv cp /data/local/tmp/home-items.xml \
  /data/data/io.github.op7418.guizangtv/shared_prefs/home-items.xml
adb shell am force-stop io.github.op7418.guizangtv
adb shell am start -n io.github.op7418.guizangtv/.FrameHomeActivity
```

写入后**必须 force-stop 再启动**，否则运行中的应用会用内存里的旧配置覆盖文件。

## 说明

这个文件里只有包名和显示名，不含任何个人数据（没有账号、没有设备标识、没有网络信息）。
