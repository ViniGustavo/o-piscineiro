# Gera as fotos do "Antes e depois" (fotos/antes-depois/*.webp) a partir de fotos/antes-depois/originais,
# usando ferramentas/render-antes-depois.html no Edge sem janela. Precisa do servidor local ligado (porta 8765).
# Fotos originais: Pexels (licença livre). A versão "antes" é uma edição feita só na água.
$root = Split-Path $PSScriptRoot -Parent
$dir = Join-Path $root 'fotos\antes-depois'
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$perfil = Join-Path $env:TEMP 'opiscineiro-edge'
$dom = & $edge --headless=new --disable-gpu --no-first-run "--user-data-dir=$perfil" '--virtual-time-budget=40000' '--dump-dom' 'http://localhost:8765/ferramentas/render-antes-depois.html?exportar=1' 2>$null | Out-String
$ms = [regex]::Matches($dom, '<pre data-nome="([^"]+)">data:image/webp;base64,([^<]+)</pre>')
foreach ($m in $ms) {
  $dest = Join-Path $dir ($m.Groups[1].Value + '.webp')
  [IO.File]::WriteAllBytes($dest, [Convert]::FromBase64String($m.Groups[2].Value))
  '{0}.webp  {1:N0} KB' -f $m.Groups[1].Value, ((Get-Item $dest).Length / 1KB)
}
'arquivos gerados: ' + $ms.Count
