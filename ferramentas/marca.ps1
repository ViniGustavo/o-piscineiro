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
foreach ($i in $itens) {
  $saida = Join-Path $dir $i[0]
  if (Test-Path $saida) { Remove-Item $saida }
  $px = $i[2]
  & $edge --headless=new --disable-gpu --hide-scrollbars --no-first-run "--user-data-dir=$perfil" `
    '--default-background-color=00000000' "--window-size=$px,$px" '--virtual-time-budget=8000' `
    "--screenshot=$saida" ($base + $i[1]) 2>$null | Out-Null
  $img = [Drawing.Image]::FromFile($saida)
  '{0}  {1}x{2}  {3:N0} KB' -f $i[0], $img.Width, $img.Height, ((Get-Item $saida).Length / 1KB)
  $img.Dispose()
}
