# NOTICE

## 桌面程序

`apps/GuizangTV-0.3.0-a5.1.apk` 编译自 [op7418/guizang-tv](https://github.com/op7418/guizang-tv) v0.3.0，原作者 op7418，MIT License。

本仓库的修改（minSdk 22、Java 8 API 替换、desugaring、电量显示、待机条目、删除小米桌面入口）同样以 MIT 发布，修改明细见 [`docs/06-修改说明.md`](docs/06-修改说明.md)。

上游项目本身参考了 [Gathin23/cleanyourtv](https://github.com/Gathin23/cleanyourtv) 与 [nthnclrk/CleanFrame](https://github.com/nthnclrk/CleanFrame)，相关署名见上游仓库的 NOTICE。

## 壁纸

归藏内置的五张壁纸来自 Unsplash，适用 [Unsplash License](https://unsplash.com/license)：

| 名称 | 摄影师 | 来源 |
|---|---|---|
| 雾中雪岭 | Arina Avdzhian | unsplash.com/photos/rSYsP5TlEAk |
| 雨林山路 | Geio Tischler | unsplash.com/photos/hqzyUL3M21k |
| 热带绿叶 | Łukasz Rawa | unsplash.com/photos/4axNezh03UA |
| 山间彩虹 | Pascal Debrunner | unsplash.com/photos/vwFvhJf6u_I |
| 流光花影 | Patrick Shaun | unsplash.com/photos/JtF_FvXVQQI |

壁纸素材的版权不属于本项目，随 APK 分发时沿用 Unsplash License，不转为 MIT。

## 第三方应用

以下应用**不在本仓库中分发**，请通过官方渠道获取：

- 河南IPTV（`com.brlf.tvlivelaunch`）——运营商应用，版权归其所有
- OK影视（`com.fongmi.android.tv`）——开源项目，见其官方发布页

本仓库只提供包名与配置示例，不对这些应用的合规性负责。

## 工具与漏洞

- Dirty COW（CVE-2016-5195）利用工具来自 [davidqphan/dirtycow-android-poc](https://github.com/davidqphan/dirtycow-android-poc)，按其原始许可使用
- 该工具仅用于用户本人在自己设备上获取调试权限，请勿用于他人设备
