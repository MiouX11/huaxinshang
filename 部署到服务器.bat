@echo off
chcp 65001 >nul
set SERVER=120.76.231.120
set PASS=2000105Li@

echo ========================================
echo   华新商官网 — 一键部署到服务器
echo ========================================
echo.
echo 服务器: %SERVER%
echo.

:: 安装 sshpass (如果还没有)
where sshpass >nul 2>&1
if %errorlevel% neq 0 (
    echo [1/4] 正在安装必要工具...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/kevinburke/sshpass/releases/download/0.10/sshpass.exe' -OutFile '%TEMP%\sshpass.exe'" 2>nul
    copy "%TEMP%\sshpass.exe" "C:\Windows\System32\sshpass.exe" >nul 2>&1
)

:: 上传网站文件
echo [2/4] 正在上传网站文件...
sshpass -p "%PASS%" scp -o StrictHostKeyChecking=no -r "index.html" "hero-bg.jpg" "hero-bg.png" "logo.jpg" "*.png" root@%SERVER%:/tmp/huaxinshang/ 2>&1

:: 安装 Nginx
echo [3/4] 正在安装 Nginx...
sshpass -p "%PASS%" ssh -o StrictHostKeyChecking=no root@%SERVER% "yum install -y nginx && systemctl enable nginx && systemctl start nginx" 2>&1

:: 部署网站
echo [4/4] 正在部署网站...
sshpass -p "%PASS%" ssh -o StrictHostKeyChecking=no root@%SERVER% "rm -rf /usr/share/nginx/html/* && cp -r /tmp/huaxinshang/* /usr/share/nginx/html/ && chmod -R 755 /usr/share/nginx/html && nginx -s reload" 2>&1

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   部署成功！
    echo   访问地址: http://%SERVER%
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   自动部署失败，请手动操作：
    echo.
    echo   1. 打开 cmd，输入：
    echo      ssh root@%SERVER%
    echo      密码: %PASS%
    echo.
    echo   2. 登录后依次执行：
    echo      yum install -y nginx
    echo      systemctl start nginx
    echo      exit
    echo.
    echo   3. 然后用 WinSCP 或 scp 把网站文件
    echo      传到 /usr/share/nginx/html/
    echo.
    echo   文件位置: %~dp0
    echo ========================================
)

pause
