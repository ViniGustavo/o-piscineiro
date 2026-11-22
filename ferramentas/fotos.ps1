# Salva as fotos na pasta "fotos", aponta a pagina para elas e cria a imagem de compartilhamento
$root = Split-Path $PSScriptRoot -Parent
$dir = Join-Path $root 'fotos'
New-Item -ItemType Directory -Force $dir | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = New-Object Net.WebClient
$wc.Headers.Add('User-Agent', 'Mozilla/5.0')

$fotos = @(
  @('abertura-1.jpg',     'images\.unsplash\.com/photo-1509577330292-0532d33c053e', 'https://images.unsplash.com/photo-1509577330292-0532d33c053e?auto=format&fit=crop&w=1920&q=80&fm=jpg'),
  @('abertura-2.jpg',     'images\.unsplash\.com/photo-1742353980377-b8e42932c590', 'https://images.unsplash.com/photo-1742353980377-b8e42932c590?auto=format&fit=crop&w=1920&q=80&fm=jpg'),
  @('abertura-3.jpg',     'images\.unsplash\.com/photo-1782203601219-c772fac676dc', 'https://images.unsplash.com/photo-1782203601219-c772fac676dc?auto=format&fit=crop&w=1920&q=80&fm=jpg'),
  @('servico-ph.jpg',     'images\.pexels\.com/photos/7223304/pexels-photo-7223304\.jpeg', 'https://images.pexels.com/photos/7223304/pexels-photo-7223304.jpeg?auto=compress&cs=tinysrgb&w=1400'),
  @('servico-cloro.jpg',  'images\.pexels\.com/photos/8974468/pexels-photo-8974468\.jpeg', 'https://images.pexels.com/photos/8974468/pexels-photo-8974468.jpeg?auto=compress&cs=tinysrgb&w=1400'),
  @('servico-limpeza.jpg','images\.unsplash\.com/photo-1784935839477-207ce2c61108', 'https://images.unsplash.com/photo-1784935839477-207ce2c61108?auto=format&fit=crop&w=1400&q=80&fm=jpg')
)
$p = Join-Path $root 'index.html'
$h = [IO.File]::ReadAllText($p, [Text.Encoding]::UTF8)
foreach ($f in $fotos) {
  $dest = Join-Path $dir $f[0]
  $wc.Headers['User-Agent'] = 'Mozilla/5.0'
  $wc.DownloadFile($f[2], $dest)
  $b = [IO.File]::ReadAllBytes($dest)
  $jpg = ($b[0] -eq 0xFF -and $b[1] -eq 0xD8)
  "{0}  {1:N0} KB  jpeg={2}" -f $f[0], ($b.Length / 1KB), $jpg
  if ($jpg) { $h = [regex]::Replace($h, 'https://' + $f[1] + '[^"]*', 'fotos/' + $f[0]) }
}
[IO.File]::WriteAllText($p, $h, (New-Object Text.UTF8Encoding($false)))

# Imagem de compartilhamento 1200 x 630
Add-Type -AssemblyName System.Drawing
$src = [Drawing.Image]::FromFile((Join-Path $dir 'abertura-1.jpg'))
$bmp = New-Object Drawing.Bitmap 1200, 630
$g = [Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = 'HighQualityBicubic'; $g.SmoothingMode = 'AntiAlias'; $g.TextRenderingHint = 'AntiAliasGridFit'
$s = [math]::Max(1200 / $src.Width, 630 / $src.Height)
$w = $src.Width * $s; $hh = $src.Height * $s
$g.DrawImage($src, [single]((1200 - $w) / 2), [single]((630 - $hh) / 2), [single]$w, [single]$hh)
$g.FillRectangle((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(165, 7, 42, 66))), 0, 0, 1200, 630)
$g.FillRectangle((New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(255, 245, 165, 50))), 0, 612, 1200, 18)
$f1 = New-Object Drawing.Font 'Segoe UI', 92, ([Drawing.FontStyle]::Bold), ([Drawing.GraphicsUnit]::Pixel)
$f2 = New-Object Drawing.Font 'Segoe UI', 34, ([Drawing.FontStyle]::Regular), ([Drawing.GraphicsUnit]::Pixel)
$sun = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(255, 245, 165, 50))
$g.DrawString('O', $f1, $sun, 70, 330)
$ow = $g.MeasureString('O', $f1).Width
$g.DrawString('PISCINEIRO', $f1, [Drawing.Brushes]::White, (70 + $ow - 18), 330)
$g.DrawString('Garantindo o seu lazer', $f2, $sun, 76, 450)
$g.DrawString('Limpeza de piscinas em Barra Velha, SC', $f2, [Drawing.Brushes]::White, 76, 500)
$enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$ep = New-Object Drawing.Imaging.EncoderParameters 1
$ep.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), ([long]88)
$bmp.Save((Join-Path $dir 'compartilhar.jpg'), $enc, $ep)
$g.Dispose(); $bmp.Dispose(); $src.Dispose()
"compartilhar.jpg  {0:N0} KB" -f ((Get-Item (Join-Path $dir 'compartilhar.jpg')).Length / 1KB)
"restam links externos de foto: " + ([regex]::Matches($h, 'https://images\.(unsplash|pexels)')).Count
