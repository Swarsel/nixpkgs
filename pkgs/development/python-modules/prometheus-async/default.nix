{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  prometheus-client,
  pytest-asyncio,
  pytestCheckHook,
  twisted,
  typing-extensions,
  wrapt,
}:

buildPythonPackage rec {
  pname = "prometheus-async";
  version = "26.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "prometheus-async";
    rev = version;
    hash = "sha256-wQ1RdJyD/M6VO1/6DSr9Pzd5FpB4zgNE/mIa7FH5gtk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-asyncio
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    prometheus-client
    typing-extensions
    wrapt
  ];

  optional-dependencies = {
    aiohttp = [ aiohttp ];
    consul = [ aiohttp ];
    twisted = [ twisted ];
  };

  pyproject = true;
  pythonImportsCheck = [ "prometheus_async" ];

  meta = {
    description = "Async helpers for prometheus_client";
    homepage = "https://github.com/hynek/prometheus-async";
    changelog = "https://github.com/hynek/prometheus-async/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
