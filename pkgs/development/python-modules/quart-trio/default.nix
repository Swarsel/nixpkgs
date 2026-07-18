{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  exceptiongroup,
  hypercorn,
  # build-system
  pdm-backend,
  # tests
  pytest-cov-stub,
  pytest-trio,
  pytestCheckHook,
  pythonOlder,
  quart,
  trio,
}:

buildPythonPackage rec {
  pname = "quart-trio";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "pgjones";
    repo = "quart-trio";
    tag = version;
    hash = "sha256-n41XATex20iw3ZYxud/5cTdx+F6tTQQJmP91TIw2xJo=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-trio
    pytestCheckHook
  ];

  build-system = [
    pdm-backend
  ];

  dependencies = [
    hypercorn
    quart
    trio
  ]
  ++ hypercorn.optional-dependencies.trio;

  pyproject = true;

  pythonImportsCheck = [
    "quart_trio"
  ];

  meta = {
    description = "Quart-Trio is an extension for Quart to support the Trio event loop";
    homepage = "https://github.com/pgjones/quart-trio";
    changelog = "https://github.com/pgjones/quart-trio/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
