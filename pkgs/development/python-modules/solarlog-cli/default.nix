{
  lib,
  fetchFromGitHub,
  aiohttp,
  aioresponses,
  bcrypt,
  buildPythonPackage,
  hatchling,
  mashumaro,
  pytest-aio,
  pytestCheckHook,
  pythonOlder,
  syrupy,
}:

buildPythonPackage rec {
  pname = "solarlog-cli";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "dontinelli";
    repo = "solarlog_cli";
    tag = "v${version}";
    hash = "sha256-sZ3H2x4QkDMjxo50HHEktfdjOwwGqdPr8tiUq6AafS4=";
  };

  nativeCheckInputs = [
    aioresponses
    pytest-aio
    pytestCheckHook
    syrupy
  ];

  build-system = [ hatchling ];

  dependencies = [
    aiohttp
    bcrypt
    mashumaro
  ];

  disabled = pythonOlder "3.12";
  pyproject = true;
  pythonImportsCheck = [ "solarlog_cli" ];

  meta = {
    description = "Python library to access the Solar-Log JSON interface";
    homepage = "https://github.com/dontinelli/solarlog_cli";
    changelog = "https://github.com/dontinelli/solarlog_cli/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
