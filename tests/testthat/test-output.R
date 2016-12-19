context("output")

cnpj <- '00000000000191'

has_conn <- function() {
  u_check <- 'http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Solicitacao2.asp'
  r <- try({httr::GET(u_check, httr::timeout(3))}, silent = TRUE)
  !is.null(r) && (r[['status_code']] == 200)
}

if (has_conn()) {
  test_that("downloads html when output is html", {
    r <- buscar_cnpj(cnpj, output = 'html')
    f <- paste0(cnpj, '.html')
    expect_true(r)
    expect_true(file.exists(f))
    if (file.exists(f)) file.remove(f)
  })

  test_that("downloads html and returns df when output is both", {
    r <- buscar_cnpj(cnpj, output = 'both')
    f <- paste0(cnpj, '.html')
    expect_true(file.exists(f))
    expect_is(r, 'tbl_df')
    if (file.exists(f)) file.remove(f)
  })

  test_that("returns df when output is df", {
    r <- buscar_cnpj(cnpj, output = 'df')
    f <- paste0(cnpj, '.html')
    expect_false(file.exists(f))
    expect_is(r, 'tbl_df')
    if (file.exists(f)) file.remove(f)
  })
}


