# O Piscineiro

Site de apresentação do O Piscineiro — limpeza e manutenção de piscinas em Barra Velha, SC. *Garantindo o seu lazer.*

Página estática: tudo fica em `index.html` (HTML, CSS e JS), com as fotos em `fotos/`, o logo em `logo.svg` e o ícone da aba em `icone.svg`.

## Ver no computador

Abra `index.html` no navegador, ou rode o servidor local (Windows PowerShell):

```powershell
powershell -ExecutionPolicy Bypass -File .\ferramentas\serve.ps1
```

e acesse http://localhost:8765.

## Scripts de apoio (`ferramentas/`)

- `serve.ps1` — servidor local simples.
- `mapa.ps1` — gera o mapa de Santa Catarina a partir das malhas do IBGE.
- `fotos.ps1` — baixa as fotos originais em JPG (Unsplash/Pexels, licença livre).
- `antes-depois.ps1` — gera as fotos da seção "Antes e depois" (`fotos/antes-depois/`) a partir de fotos reais de piscinas limpas (Pexels, licença livre); a versão "antes" é uma edição feita só na água (`render-antes-depois.html`).
- `imagens.ps1` — com o servidor local ligado, usa o Edge sem janela para gerar `icone-180.png` (ícone do iPhone), `fotos/compartilhar.jpg` (prévia do link) e as fotos em WebP usadas no site, a partir dos moldes `render-*.html`.
