# Gera os arquivos da marca na pasta "marca" a partir de ferramentas/render-marca.html (Edge sem janela).
# Precisa do servidor local ligado (ferramentas/serve.ps1, porta 8765).
$root = Split-Path $PSScriptRoot -Parent
$dir = Join-Path $root 'marca'
New-Item -ItemType Directory -Force $dir | Out-Null
$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$perfil = Join-Path $env:TEMP 'opiscineiro-edge'
$base = 'http://localhost:8765/ferramentas/render-marca.html'

$itens = @(
  @('perfil-redes.png',          '?v=emblema&fundo=1', 1080),
  @('perfil-redes-com-nome.png', '?v=nome&fundo=1',    1080),
  @('logo-emblema.png',          '?v=emblema',         2000),
  @('logo-com-nome.png',         '?v=nome',            2000)
)
Add-Type -AssemblyName System.Drawing
function Gerar($nome, $url, $w, $h) {
  $saida = Join-Path $dir $nome
  if (Test-Path $saida) { Remove-Item $saida }
  & $edge --headless=new --disable-gpu --hide-scrollbars --no-first-run "--user-data-dir=$perfil" `
    '--default-background-color=00000000' "--window-size=$w,$h" '--virtual-time-budget=8000' `
    "--screenshot=$saida" $url 2>$null | Out-Null
  $img = [Drawing.Image]::FromFile($saida)
  '{0}  {1}x{2}  {3:N0} KB' -f $nome, $img.Width, $img.Height, ((Get-Item $saida).Length / 1KB)
  $img.Dispose()
}
foreach ($i in $itens) { Gerar $i[0] ($base + $i[1]) $i[2] $i[2] }

# Capa do Facebook (usa o logo-emblema.png gerado acima)
Gerar 'capa-facebook.png' 'http://localhost:8765/ferramentas/render-banner.html' 1640 624

# Pacote .zip com todas as imagens
$zip = Join-Path $dir 'o-piscineiro-marca.zip'
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path (Join-Path $dir '*.png') -DestinationPath $zip
'o-piscineiro-marca.zip  {0:N0} KB' -f ((Get-Item $zip).Length / 1KB)
