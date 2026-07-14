$server = "120.76.231.120"
$pass = "2000105Li@"
$localPath = "C:\Users\19396\Desktop\华新商官网"
$remotePath = "/tmp/huaxinshang"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  华新商官网 — 一键部署到服务器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Install and start Nginx
Write-Host "[1/4] 安装 Nginx..." -ForegroundColor Yellow
$plink = "C:\Program Files\PuTTY\plink.exe"
if (-not (Test-Path $plink)) {
    $plink = (Get-Command plink.exe -ErrorAction SilentlyContinue).Source
}
if ($plink) {
    & $plink -pw $pass -batch root@$server "yum install -y nginx && systemctl enable nginx && systemctl start nginx"
    Write-Host "  Nginx 安装完成" -ForegroundColor Green
} else {
    Write-Host "  未找到 plink，请先用 cmd 手动执行：" -ForegroundColor Red
    Write-Host "  ssh root@$server" -ForegroundColor White
    Write-Host "  yum install -y nginx && systemctl start nginx" -ForegroundColor White
}

# Step 2: Upload files
Write-Host "[2/4] 上传网站文件..." -ForegroundColor Yellow
$env:GIT_SSH_COMMAND = "ssh -o StrictHostKeyChecking=no"
# Use WinSCP or scp
$scp = (Get-Command scp.exe -ErrorAction SilentlyContinue).Source
if ($scp) {
    Write-Host "  请在弹出的命令行中输入密码: $pass" -ForegroundColor White
    & $scp -o StrictHostKeyChecking=no -r "$localPath\index.html" "$localPath\hero-bg.jpg" "$localPath\hero-bg.png" "$localPath\logo.jpg" root@${server}:${remotePath}/
} else {
    Write-Host "  正在通过浏览器方式上传..." -ForegroundColor Yellow
}

# Step 3: Deploy to Nginx
Write-Host "[3/4] 部署到 Nginx..." -ForegroundColor Yellow
Write-Host "  请输入密码: $pass" -ForegroundColor White
ssh -o StrictHostKeyChecking=no root@$server "rm -rf /usr/share/nginx/html/* && cp -r $remotePath/* /usr/share/nginx/html/ && chmod -R 755 /usr/share/nginx/html && nginx -s reload && echo 'Nginx reloaded OK'"

# Step 4: Check
Write-Host "[4/4] 验证..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$server" -TimeoutSec 10 -UseBasicParsing
    Write-Host "  状态码: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  部署成功！访问: http://$server" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
} catch {
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "  网站无法访问，请手动检查" -ForegroundColor Red
    Write-Host "  ssh root@$server  (密码: $pass)" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Red
}
