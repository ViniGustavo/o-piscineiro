# Gera icone-180.png, fotos/compartilhar.jpg e as fotos em WebP usando o Edge sem janela.
# Precisa do servidor local ligado (ferramentas/serve.ps1, porta 8765).
$root = Split-Path $PSScriptRoot -Parent
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$base = 'http://localhost:8765/ferramentas'
$perfil = Join-Path $env:TEMP 'opiscineiro-edge'
$comum = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--no-first-run', "--user-data-dir=$perfil")
Add-Type -AssemblyName System.Drawing

function Foto($url, $w, $h, $saida) {
  if (Test-Path $saida) { Remove-Item $saida }
  & $edge @comum "--window-size=$w,$h" '--virtual-time-budget=8000' "--screenshot=$saida" $url | Out-Null
  $t = 0; while (-not (Test-Path $saida) -and $t -lt 60) { Start-Sleep -Milliseconds 500; $t++ }
}

# 1) Icone da tela inicial do iPhone
$ico = Join-Path $root 'icone-180.png'
Foto "$base/render-icone.html" 180 180 $ico
'icone-180.png  {0:N1} KB' -f ((Get-Item $ico).Length / 1KB)

# 2) Imagem de compartilhamento (PNG -> JPG)
$png = Join-Path $env:TEMP 'opiscineiro-compartilhar.png'
Foto "$base/render-compartilhar.html" 1200 630 $png
$img = [Drawing.Image]::FromFile($png)
$enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), ([long]88)
$jpg = Join-Path $root 'fotos\compartilhar.jpg'
$img.Save($jpg, $enc, $ep); $img.Dispose(); Remove-Item $png
'compartilhar.jpg  {0}x{1}  {2:N0} KB' -f 1200, 630, ((Get-Item $jpg).Length / 1KB)

# 3) Fotos em WebP
$dom = & $edge @comum '--virtual-time-budget=30000' '--dump-dom' "$base/render-webp.html" | Out-String
$ms = [regex]::Matches($dom, '<pre data-nome="([^"]+)">data:image/webp;base64,([^<]+)</pre>')
foreach ($m in $ms) {
  $nome = $m.Groups[1].Value
  $dest = Join-Path $root ("fotos\" + $nome + '.webp')
  [IO.File]::WriteAllBytes($dest, [Convert]::FromBase64String($m.Groups[2].Value))
  $jpgAntigo = (Get-Item (Join-Path $root ("fotos\" + $nome + '.jpg'))).Length
  '{0}.webp  {1:N0} KB  (jpg era {2:N0} KB)' -f $nome, ((Get-Item $dest).Length / 1KB), ($jpgAntigo / 1KB)
}
'webp gerados: ' + $ms.Count
