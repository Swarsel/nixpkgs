{
  lib,
  fetchFromGitHub,
  anyio,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tiny-proxy";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "romis2012";
    repo = "tiny-proxy";
    tag = "v${version}";
    hash = "sha256-59T09qcOstl/yfzQmNlTNxGerQethZntwDAHwz/5FFM=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ anyio ];
  # The tests depend on httpx-socks, whose tests depend on tiny-proxy.
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "tiny_proxy" ];

  meta = {
    description = "SOCKS5/SOCKS4/HTTP proxy server";
    homepage = "https://github.com/romis2012/tiny-proxy";
    changelog = "https://github.com/romis2012/tiny-proxy/releases/tag/v${version}";
    license = lib.licenses.asl20;
  };
}
