@echo off
chcp 65001 >nul
echo ========================================
echo   华新商官网 - 一键上传到 GitHub
echo ========================================
echo.

REM 检查 git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 没有安装 Git，请先下载安装：https://git-scm.com/download/win
    pause
    exit /b 1
)

REM 进入网站文件夹
cd /d "%~dp0"

REM 初始化 git（如果还没有）
if not exist ".git" (
    git init
    git checkout -b main
)

REM 添加所有文件
git add -A
git commit -m "华新商官网上线" 2>nul
if %errorlevel% neq 0 (
    echo 文件没有变化，跳过提交
)

echo.
echo 正在推送到 GitHub...
echo 如果弹出登录窗口，请选择 "Sign in with your browser"
echo.

REM 设置远程仓库并推送
git remote remove origin 2>nul
git remote add origin https://github.com/mioux11/huaxinshang.git
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo   上传成功！
    echo.
    echo   接下来请手动操作：
    echo   1. 打开 https://github.com/mioux11/huaxinshang/settings/pages
    echo   2. Branch 选 main，点 Save
    echo   3. 等待1分钟，访问：
    echo      https://mioux11.github.io/huaxinshang/
    echo ========================================
) else (
    echo.
    echo ========================================
    echo   推送失败，尝试备用方法...
    echo ========================================
    echo.
    echo   请手动操作：
    echo   1. 打开 https://github.com/new
    echo   2. 仓库名填 huaxinshang，选 Public，不要勾 README
    echo   3. 点 Create repository
    echo   4. 把当前文件夹所有文件拖进 GitHub 网页
    echo   5. 点 Commit changes
    echo   6. Settings ^> Pages ^> 选 main ^> Save
    echo.
    echo   当前文件夹路径：%~dp0
)

pause
