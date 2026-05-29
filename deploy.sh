#!/bin/bash
set -e

USERNAME="saulgoodmanngabriel"
REPO="baby-tracker"
TOKEN="$1"

if [ -z "$TOKEN" ]; then
    echo "用法: bash deploy.sh <GitHub Token>"
    echo "获取 Token: https://github.com/settings/tokens/new"
    echo "勾选 'repo' 权限"
    exit 1
fi

echo "🚀 开始部署 baby-tracker 到 GitHub Pages..."

# 1. 创建仓库
echo "📦 创建仓库..."
curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name":"'$REPO'","private":false}' > /dev/null

# 2. 初始化 git
echo "🔧 初始化仓库..."
git init
git add .
git commit -m "Initial baby-tracker PWA"

# 3. 推送到 GitHub
echo "📤 推送代码..."
git remote add origin https://$TOKEN@github.com/$USERNAME/$REPO.git
git branch -M main
git push -u origin main

# 4. 开启 GitHub Pages
echo "🌐 开启 Pages..."
curl -s -X POST \
  -H "Authorization: token $TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$USERNAME/$REPO/pages \
  -d '{"source":{"branch":"main","path":"/"}}' > /dev/null

# 5. 等待部署
sleep 3

# 6. 检查部署状态
echo "⏳ 检查部署状态..."
STATUS=$(curl -s -H "Authorization: token $TOKEN" \
  https://api.github.com/repos/$USERNAME/$REPO/pages \
  | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

echo ""
echo "✅ 部署完成！"
echo "📱 访问地址: https://$USERNAME.github.io/$REPO"
echo "📊 部署状态: $STATUS"
echo ""
echo "⏱️ 首次部署可能需要 1-2 分钟生效"
echo "如果 404，请稍等再刷新"
