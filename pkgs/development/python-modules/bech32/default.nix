{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "bech32";
  version = "1.2.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-fW24IUYDvXhx/PpsCCbvaLhbCr2Q+iHChanF4h0r2Jk=";
  };

  __structuredAttrs = true;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "bech32" ];

  meta = {
    homepage = "https://github.com/fiatjaf/bech32";
    license = with lib.licenses; [ mit ];
  };
})
