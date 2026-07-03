# 폐암 다당류 irAE 피치덱 — GitHub Pages 배포 스크립트
# 사용법(인증 후): 이 폴더에서  powershell -File deploy.ps1  실행
# (인증이 안 돼 있으면 먼저:  gh auth login  )

$ErrorActionPreference = "Stop"
$env:Path += ";C:\Program Files\GitHub CLI"

$RepoName = "wku-1jo-pitch-deck"   # 원하는 저장소 이름으로 변경 가능

# 1) 인증 확인
gh auth status
if ($LASTEXITCODE -ne 0) { throw "GitHub 인증 필요: 'gh auth login' 먼저 실행하세요." }

# 2) 저장소 생성 + 현재 폴더 푸시 (공개)
gh repo create $RepoName --public --source=. --remote=origin --push

# 3) GitHub Pages 활성화 (main 브랜치 루트)
$owner = (gh api user --jq ".login").Trim()
$body = '{"source":{"branch":"main","path":"/"}}'
try {
  $body | gh api -X POST "repos/$owner/$RepoName/pages" --input - | Out-Null
} catch {
  # 이미 있으면 소스만 갱신
  $body | gh api -X PUT "repos/$owner/$RepoName/pages" --input - | Out-Null
}

# 4) 배포 URL 출력
Start-Sleep -Seconds 3
$url = "https://$owner.github.io/$RepoName/"
Write-Host ""
Write-Host "==================================================" -ForegroundColor Green
Write-Host " 배포 완료! (Pages 빌드에 1~2분 소요)" -ForegroundColor Green
Write-Host " URL: $url" -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Green
Write-Host ""
Write-Host "이후 수정 배포:  git add -A; git commit -m '수정'; git push  (Pages 자동 갱신)"
