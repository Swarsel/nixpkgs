{
  lib,
  aiohttp,
  buildPythonPackage,
  fetchPypi,
  oauthlib,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "aiohttp-oauthlib";
  version = "0.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-iTzRpZ3dDC5OmA46VE+XELfE/7nie0zQOLUf4dcDk7c=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    oauthlib
    aiohttp
  ];

  # Package has no tests.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "oauthlib integration for aiohttp clients";
    homepage = "https://git.sr.ht/~whynothugo/aiohttp-oauthlib";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sumnerevans ];
  };
}
