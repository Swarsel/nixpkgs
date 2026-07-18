{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  tzdata,
}:

buildPythonPackage rec {
  pname = "aiozoneinfo";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "bluetooth-devices";
    repo = "aiozoneinfo";
    tag = "v${version}";
    hash = "sha256-7qd6Yk/K4BLocu8eQK0hLaw2r1jhWIHBr9W4KsAvmx8=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];
  dependencies = [ tzdata ];
  pyproject = true;
  pythonImportsCheck = [ "aiozoneinfo" ];

  meta = {
    description = "Tools to fetch zoneinfo with asyncio";
    homepage = "https://github.com/bluetooth-devices/aiozoneinfo";
    changelog = "https://github.com/bluetooth-devices/aiozoneinfo/blob/${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
