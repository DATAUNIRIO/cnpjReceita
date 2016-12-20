#' Busca um CNPJ no site da Receita Federal
#'
#' Realiza uma busca de um CNPJ na Receita Federal e salva resultados em arquivo.
#'
#' @param cnpj número do CNPJ, com ou sem os caracteres especiais.
#' @param output tipo de output: "df" retorna uma \code{tibble}, "html" salva um arquivo HTML, "both" retorna a \code{tibble} e salva um aquivo HTML.
#' @param dir pasta onde o arquivo html será salvo. Default diretório atual.
#'
#' @return Se \code{output} for "df" ou "both", retorna uma \code{tibble} com resultados após scraping.
#' @export
buscar_cnpj <- function(cnpj, output = 'both', dir = '.') {
  cnpj <- check_cnpj(cnpj)
  arq_html <- sprintf('%s/%s.html', dir, cnpj)
  tentativas <- 0
  while (!file.exists(arq_html) || (file.size(arq_html) == 8391 && tentativas < 10)) {
    tentativas <- tentativas + 1
    if (tentativas > 1) cat(sprintf('Tentativa %02d...\n', tentativas))
    try({
      r <- baixar_um(cnpj, dir, arq_html)
    })
    Sys.sleep(1)
  }
  if (output %in% c('both', 'df')) {
    txt <- readr::read_file(arq_html, locale = readr::locale(encoding = 'latin1'))
    d <- scrape_cnpj(txt)
    if(output == 'df') file.remove(arq_html)
    return(d)
  }
  return(invisible(TRUE))
}

scrape_cnpj <- function(x) {
  txts <- x %>%
    xml2::read_html() %>%
    rvest::html_nodes(xpath = '//td[contains(@style, "BORDER-RIGHT")]') %>%
    rvest::html_text() %>%
    stringr::str_replace_all('[\t \r]+', ' ') %>%
    stringr::str_replace_all('(\n )+', '\n') %>%
    stringr::str_trim()
  txts <- txts[txts != '']
  txts %>%
    stringr::str_split_fixed(' \n', 2) %>%
    tibble::as_tibble() %>%
    purrr::set_names(c('key', 'value'))
}

check_cnpj <- function(cnpj) {
  cnpj <- gsub('[^0-9]', '', cnpj)
  if (nchar(cnpj) != 14) stop('CNPJ Invalido.')
  cnpj
}

baixar_um <- function(cnpj, dir, arq_html) {
  to <- httr::timeout(3)
  u_consulta <- u_receita(cnpj)
  httr::handle_reset(u_consulta)
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  url_gera_captcha <- u_captcha_img()
  url_audio <- u_captcha_audio()
  solicitacao <- httr::GET(u_consulta)
  data_hora <- stringr::str_replace_all(lubridate::now(), "[^0-9]", "")
  if (is.null(dir)) dir <- tempdir()
  arq <- tempfile(pattern = data_hora, tmpdir = dir)
  wd_aud <- httr::write_disk(paste0(arq, ".wav"), overwrite = TRUE)
  wd_img <- httr::write_disk(paste0(arq, ".png"), overwrite = TRUE)
  imagem <- httr::GET(url_gera_captcha, wd_img, to)
  audio <- httr::GET(url_audio, wd_aud, to)
  while (as.numeric(audio$headers[["content-length"]]) < 1) {
    sl <- 3
    msg <- sprintf("Aconteceu algum problema. Tentando novamente em %d segundos...", sl)
    message(msg)
    Sys.sleep(sl)
    imagem <- httr::GET(url_gera_captcha, wd_img, to)
    audio <- httr::GET(url_audio, wd_aud, to)
  }

  captcha <- captchaReceitaAudio::predizer(paste0(arq, ".wav"))
  file.remove(paste0(arq, ".wav"))
  file.remove(paste0(arq, ".png"))
  dados <- form_data(cnpj, captcha)
  u_valid <- u_validacao()
  httr::POST(u_valid, body = dados, to,
             httr::set_cookies("flag" = '1', .cookies = unlist(httr::cookies(solicitacao))),
             encode = 'form', httr::write_disk(arq_html, overwrite = TRUE))
}

u_captcha_img <- function() {
  "http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/captcha/gerarCaptcha.asp"
}

u_captcha_audio <- function() {
  "http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/cnpjreva/captcha/gerarSom.asp"
}

u_receita <- function(cnpj = '') {
  u <- 'http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Solicitacao2.asp?cnpj=%s'
  sprintf(u, cnpj)
}

u_validacao <- function() {
  'http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/valida.asp'
}

u_result <- function(cnpj) {
  u <- 'http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Vstatus.asp?origem=comprovante&cnpj=%s'
  sprintf(u, cnpj)
}

form_data <- function(cnpj, captcha) {
  dados <- list(origem = 'comprovante',
                cnpj = cnpj,
                txtTexto_captcha_serpro_gov_br = captcha,
                submit1 = 'Consultar',
                search_type = 'cnpj')
}
