{
  lib,
  fetchFromGitHub,
  aiohttp,
  aresponses,
  attrs,
  buildPythonPackage,
  cryptography,
  poetry-core,
  pytestCheckHook,
  pytz,
}:

buildPythonPackage rec {
  pname = "pyseventeentrack";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "shaiu";
    repo = "pyseventeentrack";
    tag = "v${version}";
    hash = "sha256-aIECWBOozGdCpyqih3YNMioq4Fcc6Ttw9hiTl7m/r28=";
  };

  nativeCheckInputs = [
    aresponses
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    attrs
    cryptography
    pytz
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyseventeentrack" ];
  pythonRelaxDeps = [ "cryptography" ];

  meta = {
    description = "Simple Python API for 17track.net";
    homepage = "https://github.com/shaiu/pyseventeentrack";
    changelog = "https://github.com/shaiu/pyseventeentrack/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
