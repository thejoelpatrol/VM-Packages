$ErrorActionPreference = 'Continue'
$category = 'Productivity Tools'
$shortcutDir = Join-Path ${Env:TOOL_LIST_DIR} $category
$shortcut = Join-Path $shortcutDir 'cmder.lnk'
Remove-Item $shortcut -Force -ea 0 | Out-Null
