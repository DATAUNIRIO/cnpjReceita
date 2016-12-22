u_qsa <- function() {
  'http://www.receita.fazenda.gov.br/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_qsa.asp'
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
