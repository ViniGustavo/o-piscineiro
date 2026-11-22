# O Piscineiro

Site do O Piscineiro, limpeza e manutenção de piscinas em Barra Velha, SC.

**Site no ar:** https://opiscineiro.pages.dev/

Hospedado no Cloudflare Pages. Cada commit na branch `main` atualiza o site automaticamente.

## Estrutura

- `index.html`: a página inteira (HTML, CSS e JS)
- `fotos/`: fotos usadas no site
- `marca/`: logo, foto de perfil e capa para as redes sociais
- `ferramentas/`: scripts usados para gerar as imagens e rodar o site no computador

## Rodar no computador

```powershell
powershell -ExecutionPolicy Bypass -File .\ferramentas\serve.ps1
```

Depois é só abrir http://localhost:8765.
