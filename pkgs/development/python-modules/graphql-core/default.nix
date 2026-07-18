{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-asyncio,
  pytest-describe,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "graphql-core";
  version = "3.2.7";

  src = fetchFromGitHub {
    owner = "graphql-python";
    repo = "graphql-core";
    tag = "v${version}";
    hash = "sha256-ag8yFf6254dX2xNZMKtVBW5QtI5JOZjzgcZveuoeAss=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail ', "setuptools>=59,<81"' ""

    # avoid big pytest-benchmark dependency
    substituteInPlace setup.cfg \
      --replace-fail "addopts = --benchmark-disable" ""
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-describe
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  disabledTestPaths = [
    "tests/benchmarks"
  ];

  pyproject = true;
  pythonImportsCheck = [ "graphql" ];

  meta = {
    description = "Port of graphql-js to Python";
    homepage = "https://github.com/graphql-python/graphql-core";
    changelog = "https://github.com/graphql-python/graphql-core/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kamadorueda ];
  };
}
