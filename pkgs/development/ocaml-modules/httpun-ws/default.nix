{
  lib,
  fetchurl,
  alcotest,
  angstrom,
  base64,
  bigstringaf,
  buildDunePackage,
  faraday,
  gluten,
  httpun,
}:

buildDunePackage (finalAttrs: {
  pname = "httpun-ws";
  version = "0.2.0";

  src = fetchurl {
    url = "https://github.com/anmonteiro/httpun-ws/releases/download/${finalAttrs.version}/httpun-ws-${finalAttrs.version}.tbz";
    hash = "sha256-6uDNLg61tPyctthitxFqbw/IUDsuQ5BGvw5vTLLCl/0=";
  };

  propagatedBuildInputs = [
    angstrom
    base64
    bigstringaf
    faraday
    gluten
    httpun
  ];

  doCheck = true;
  checkInputs = [ alcotest ];

  meta = {
    description = "Websocket implementation for httpun";
    homepage = "https://github.com/anmonteiro/httpun-ws";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
