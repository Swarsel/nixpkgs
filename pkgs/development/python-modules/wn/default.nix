{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  httpx,
  pytest-benchmark,
  pytestCheckHook,
  starlette,
  tomli,
}:

buildPythonPackage rec {
  pname = "wn";
  version = "0.14.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-z2mDEFx7Qn5LKyji4CgFhxvCUblZeXLf2hjy4i6lMjQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-benchmark
  ]
  ++ optional-dependencies.web;

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ hatchling ];

  dependencies = [
    httpx
    tomli
  ];

  optional-dependencies.web = [
    starlette
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "wn" ];

  meta = {
    description = "Modern, interlingual wordnet interface for Python";
    homepage = "https://github.com/goodmami/wn";
    changelog = "https://github.com/goodmami/wn/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
  };
}
