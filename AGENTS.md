# AGENTS.md — 给 AI 助手的部署说明

你正在帮助用户把一台**天猫魔屏投影仪**（MagicProjector_A1C，Android 5.1.1 / API 22）改造成干净的第三方桌面。

请严格按顺序执行，**每一步都要验证结果再进入下一步**。遇到失败按"失败处理"分支走，不要跳过验证。

## 0. 前置条件（先确认，不满足就停下来问用户）

| 项 | 要求 | 检查方式 |
|---|---|---|
| 电视与电脑同一局域网 | 能 ping 通 | `ping <TV_IP>` |
| 电视已开 ADB 调试 | 5555 端口可连 | `adb connect <TV_IP>:5555` → `adb devices` 显示 `device` |
| 电脑有 adb | 仓库 `scripts/` 里没有，需系统自带或用 platform-tools | `adb version` |
| 用户已同意改系统 | 会安装应用、隐藏系统包 | 明确询问一次 |

把 `<TV_IP>` 替换成实际地址，例如 `192.168.1.50`。

## 1. 安装桌面与工具

```bash
adb install -r apps/GuizangTV-0.3.0-a5.1.apk
adb install -r apps/HomeFix.apk
```

验证：

```bash
adb shell pm list packages | grep -E "guizangtv|tv.fix.home"
```

两个包都要出现。

## 2. 把 HomeFix 设为设备所有者

HomeFix 是后续"切换桌面 / 隐藏系统应用 / 待机"的执行者，必须先成为 Device Owner。

```bash
adb shell dpm set-device-owner tv.fix.home/.Admin
```

期望输出 `Success: Device owner set to package tv.fix.home`。

验证：

```bash
adb shell dumpsys device_policy | grep -i "Device Owner"
```

### 失败处理

- `Not allowed to set the device owner because there are already some accounts on the device`
  → 设备上已有账号（淘宝/酷喵登录等），需要恢复出厂后才能设置。**先停下来告知用户**，不要擅自恢复出厂。
- `already has a device owner`
  → 已经设置过，跳过本步。

## 3. 切到归藏桌面

```bash
adb shell am start -n tv.fix.home/.MainActivity
```

在电视上用遥控器选「2. 使用归藏电视」，或直接点击对应按钮。它会：

- 显示归藏，隐藏酷喵（`com.youku.taitan.tv`）
- 保持其他隐藏项不变

验证：

```bash
adb shell input keyevent 3
adb shell dumpsys activity activities | grep mResumedActivity
```

应为 `io.github.op7418.guizangtv/.FrameHomeActivity`。

## 4. 应用首页配置

把 `config/home-items.sample.xml` 推到应用私有目录（归藏是 debug 签名，可用 `run-as`）：

```bash
adb push config/home-items.sample.xml /data/local/tmp/home-items.xml
adb shell run-as io.github.op7418.guizangtv cp /data/local/tmp/home-items.xml /data/data/io.github.op7418.guizangtv/shared_prefs/home-items.xml
adb shell run-as io.github.op7418.guizangtv chmod 660 /data/data/io.github.op7418.guizangtv/shared_prefs/home-items.xml
adb shell am force-stop io.github.op7418.guizangtv
adb shell am start -n io.github.op7418.guizangtv/.FrameHomeActivity
```

**重要**：写入后必须 force-stop 再启动，否则进程内缓存会覆盖新配置。

验证：首页应出现 河南IPTV / OK影视 / 应用管家 / 桌面切换 / 系统设置 / 关机 六项。
如果目标设备没装某个应用，对应的项会显示"暂时不可用"，属正常。

## 5. 隐藏系统组件（可选，按用户意愿）

在 HomeFix 里点「3. 隐藏优酷 / 广告 / 华数认证」。它会隐藏：

```
com.youku.cloud.dog          优酷配置服务
com.yunos.advert.service     广告服务
com.yunos.tv.edu             少儿大厅
com.yunos.music              咪咕爱唱（音响模式载体，隐藏后音响模式不可用）
com.android.dreams.phototable 系统屏保（厂商用它推广告）
com.yunos.ottauthclient      华数认证（开机会校验并清理应用）
com.yunos.tv.alitvasr        天猫语音
com.yunos.tv.allinone.sdk    语音 SDK
com.iflytek.aichang.tv       讯飞语音
```

**不要隐藏 `com.yunos.tv.guide`（导视）**。实测隐藏它之后，长按电源键的电源菜单会消失，按键直接变成重启。HomeFix 已经把它从清单里排除。

想恢复任意一项，点「4. 恢复以上服务」。

## 6. 待机（关机）能力

首页最后一项「关机」会发送广播 `tv.fix.home.SLEEP`，由 HomeFix 调用 `DevicePolicyManager.lockNow()` 进入待机。

前置条件（必须满足，否则点了没反应）：

1. HomeFix 是设备所有者（第 2 步）
2. HomeFix 的 device admin 已激活：

```bash
adb shell dpm set-active-admin tv.fix.home/.Admin
```

3. `res/xml/device_admin.xml` 中声明了 `<force-lock />`（仓库里的 APK 已包含）

验证：

```bash
adb shell am broadcast -a tv.fix.home.SLEEP
```

设备应息屏。唤醒用遥控器电源键。

## 7. 验收清单

| 项 | 命令/操作 | 期望 |
|---|---|---|
| 桌面 | 按 Home | 进归藏 |
| 首页六项 | 目视 | 六项齐全 |
| 待机 | 选「关机」按确认 | 息屏 |
| 唤醒 | 按电源键 | 亮屏 |
| 后台清理 | `adb shell pm list packages \| grep -c youku` | 0 |
| 重启保持 | 重启后重复上面 | 全部保持 |

## 8. 绝对不要做的事

- 不要执行 `adb shell pm uninstall` 卸载系统应用（会被系统拒绝，且可能触发校验）
- 不要尝试 `mount -o remount,rw /system`（本机 SELinux 拒绝，返回 EINVAL）
- 不要恢复出厂设置来"清理环境"（会丢失所有已完成的配置，且用户数据不可恢复）
- 不要把 `com.yunos.tv.guide` 加入隐藏清单
- 不要在没有备份 `run-as` 的情况下跑 Dirty COW（`scripts/` 里的提权脚本已包含备份步骤）

## 9. 失败处理索引

| 现象 | 处理 |
|---|---|
| `INSTALL_FAILED_OLDER_SDK` | 你装的是官方归藏包（minSdk 26），换 `apps/GuizangTV-0.3.0-a5.1.apk` |
| `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | 签名不一致，先 `adb uninstall <包名>` 再装 |
| Home 键弹出选择器 | 说明有第二个 HOME 应用可见，用 HomeFix 隐藏它 |
| 点了「关机」没反应 | 检查第 6 步的两个前置条件 |
| 应用"消失" | 多半被 HomeFix 隐藏了，点「9. 恢复 IPTV」或「4. 恢复以上服务」 |
| ADB 频繁掉线 | 设备在重启或休眠，等 30 秒重连；必要时断电重启 |

详细背景见 `docs/`。
