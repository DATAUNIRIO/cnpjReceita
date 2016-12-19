[![Travis-CI Build Status](https://travis-ci.org/jtrecenti/cnpjReceita.svg?branch=master)](https://travis-ci.org/jtrecenti/cnpjReceita)

# cnpjReceita

Webscraper que realiza consulta de CNPJ na Receita Federal.

## Instalação

```r
if (!require(devtools)) install.packages('devtools')
devtools::install_github('jtrecenti/cnpjReceita')
```

## Modo de uso

```r
library(cnpjReceita)
cnpj <- '00.000.000/0001-91'
```

Se quiser apenas salvar o HTML resultante da pesquisa na pasta `dir`, rode

```r
buscar_cnpj(cnpj, dir = './', type = 'html')
```

Se quiser somente um `data.frame` organizado com os resultados, rode

```r
d_result <- buscar_cnpj(cnpj, type = 'df')
d_result
```

Se quiser todos

## TODO

- Buscar vetor de CNPJs.
- Buscar em paralelo.
- Mais checks.

## Agradecimentos

Turminha da página [decryptr](https://github.com/decryptr).

