{
  lib,
  brotli,
  buildPythonPackage,
  colorama,
  fetchPypi,
  filetype,
  pycryptodome,
  pypng,
  pyqrcode,
  requests,
  requests-toolbelt,
  setuptools,
  ua-parser,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "discum";
  version = "1.4.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-/8TaAmfSPv/7kuymockSvC2uxXgHfuP+FXN8vuA9WHY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    brotli
    colorama
    filetype
    requests
    requests-toolbelt
    ua-parser
    websocket-client
  ];

  optional-dependencies = {
    ra = [
      pycryptodome
      pypng
      pyqrcode
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "discum" ];
  pythonRelaxDeps = [ "websocket-client" ];

  meta = {
    description = "Discord API Wrapper for Userbots/Selfbots written in Python";
    homepage = "https://pypi.org/project/discum/";
    changelog = "https://github.com/Merubokkusu/Discord-S.C.U.M/blob/v${version}/changelog.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jokatzke ];
  };
}
