{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "proxy-tools";
  version = "0.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-zLN1H1KcBH4tilhEDYayBTA88P6BRveE0cvNlPCigBA=";
    pname = "proxy_tools";
  };

  nativeBuildInputs = [ setuptools ];
  # no tests in pypi
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "proxy_tools" ];

  meta = {
    description = "Simple (hopefuly useful) Proxy (as in the GoF design pattern) implementation for Python";
    homepage = "https://github.com/jtushman/proxy_tools";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ jojosch ];
  };
}
