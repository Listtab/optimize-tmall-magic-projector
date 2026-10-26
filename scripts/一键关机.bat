@echo off
chcp 65001 >nul
setlocal

REM ============================================
REM  一键关机（reboot -p，真正断电）
REM  这是本机唯一可靠的软件关机方式
REM ============================================

REM 改成你的电视 IP
set TV_IP=192.168.1.50
set ADB=%~dp0..\platform-tools\adb.exe
if not exist "%ADB%" set ADB=adb

echo 正在连接电视 %TV_IP% ...
"%ADB%" connect %TV_IP%:5555

echo 正在关机 ...
"%ADB%" shell reboot -p

echo.
echo 已发送关机指令。若电视没有熄灭，检查电脑和电视是否在同一局域网。
pause
