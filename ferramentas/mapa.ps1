# Gera o mapa (Sul do Brasil com zoom, Santa Catarina em destaque, seta em Barra Velha) a partir das malhas do IBGE
Add-Type -AssemblyName System.Web.Extensions
$js = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$js.MaxJsonLength = 500MB
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object Net.WebClient
$wc.Encoding = [Text.Encoding]::UTF8
$inv = [Globalization.CultureInfo]::InvariantCulture

# Projecao: 1 grau de latitude = 42 px; canto superior esquerdo em lon -57.8, lat -21; quadro 760 x 520
$LON0 = -57.8; $LAT0 = -21.0; $KX = 37.8; $KY = 42.0; $W = 760; $H = 520

function RingPath($ring, $min) {
  $sb = New-Object Text.StringBuilder
  $px = 0; $py = 0; $n = 0; $dentro = $false
  foreach ($pt in $ring) {
    $x = ([double]$pt[0] - $LON0) * $KX
    $y = ($LAT0 - [double]$pt[1]) * $KY
    if ($n -gt 0 -and ([math]::Abs($x - $px) + [math]::Abs($y - $py)) -lt $min) { continue }
    if ($x -gt -40 -and $x -lt ($W + 40) -and $y -gt -40 -and $y -lt ($H + 40)) { $dentro = $true }
    $cmd = 'L'; if ($n -eq 0) { $cmd = 'M' }
    [void]$sb.Append($cmd + $x.ToString('0.#', $inv) + ' ' + $y.ToString('0.#', $inv))
    $px = $x; $py = $y; $n++
  }
  if ($n -lt 4 -or -not $dentro) { return '' }
  return $sb.ToString() + 'Z'
}
function GeomPath($g, $min) {
  $out = ''
  if ($g['type'] -eq 'Polygon') {
    foreach ($ring in $g['coordinates']) { $out += RingPath $ring $min }
  } else {
    foreach ($poly in $g['coordinates']) { foreach ($ring in $poly) { $out += RingPath $ring $min } }
  }
  return $out
}

$br = $js.DeserializeObject($wc.DownloadString('https://servicodados.ibge.gov.br/api/v3/malhas/paises/BR?formato=application/vnd.geo%2Bjson&qualidade=intermediaria&intrarregiao=UF'))
$outros = ''; $sc = ''
foreach ($f in $br['features']) {
  $d = GeomPath $f['geometry'] 1.6
  if ([string]$f['properties']['codarea'] -eq '42') { $sc = $d } else { $outros += $d }
}

function PX($lon) { return (($lon - $LON0) * $KX).ToString('0.#', $inv) }
function PY($lat) { return (($LAT0 - $lat) * $KY).ToString('0.#', $inv) }
$siglas = ''
$uf = @(@('RS', -53.4, -29.9), @('PR', -51.7, -24.9), @('SP', -49.0, -22.5), @('MS', -54.6, -21.9), @('MG', -45.3, -21.7), @('RJ', -42.9, -22.45))
foreach ($u in $uf) { $siglas += '<text x="' + (PX $u[1]) + '" y="' + (PY $u[2]) + '">' + $u[0] + '</text>' }
$bx = PX -48.685; $by = PY -26.632

$svg = @"
<svg viewBox="0 0 $W $H" role="img" aria-label="Mapa do Sul do Brasil com Santa Catarina em destaque e uma seta saindo de Barra Velha">
      <defs><marker id="ponta" viewBox="0 0 10 10" refX="7" refY="5" markerWidth="7" markerHeight="7" orient="auto"><path d="M0 0L10 5L0 10z" fill="#0B3C5D"/></marker></defs>
      <path d="$outros" fill="#fff" stroke="#9CC9D8" stroke-width="1.5" stroke-linejoin="round"/>
      <path d="$sc" fill="#F5A532" stroke="#0B3C5D" stroke-width="2.5" stroke-linejoin="round"/>
      <g font-family="Outfit,sans-serif" font-size="19" font-weight="600" fill="#0B3C5D" opacity=".4" text-anchor="middle" letter-spacing="2">$siglas</g>
      <text x="$(PX -50.75)" y="$(PY -27.5)" font-family="Outfit,sans-serif" font-size="20" font-weight="700" fill="#0B3C5D" letter-spacing="2" text-anchor="middle">SC</text>
      <text x="610" y="480" font-family="Outfit,sans-serif" font-size="13" font-style="italic" fill="#0B3C5D" opacity=".45" letter-spacing="3" text-anchor="middle">Oceano Atl&#226;ntico</text>
      <circle class="pulso" cx="$bx" cy="$by" r="9" fill="#0B3C5D"/>
      <circle cx="$bx" cy="$by" r="7" fill="#0B3C5D" stroke="#fff" stroke-width="3"/>
      <path d="M356 239Q412 240 452 272" fill="none" stroke="#0B3C5D" stroke-width="4" stroke-linecap="round" marker-end="url(#ponta)"/>
      <text x="470" y="282" font-family="Outfit,sans-serif" font-size="15" font-weight="600" fill="#0B3C5D" letter-spacing="4">ATENDIMENTO EM</text>
      <text x="468" y="322" font-family="Outfit,sans-serif" font-size="40" font-weight="800" fill="#0B3C5D">BARRA VELHA</text>
    </svg>
"@
$p = Join-Path (Split-Path $PSScriptRoot -Parent) 'index.html'
$h = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
$h = [regex]::Replace($h, '(?s)(<div class="mapa">).*?(</div>)', { param($m) $m.Groups[1].Value + $svg + $m.Groups[2].Value }, 1)
[IO.File]::WriteAllText($p, $h, (New-Object Text.UTF8Encoding($false)))
"outros=$($outros.Length) sc=$($sc.Length) barra=$bx,$by"
