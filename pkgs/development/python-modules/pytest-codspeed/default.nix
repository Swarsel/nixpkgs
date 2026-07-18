{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  pytest,
  pytest-benchmark,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  rich,
  semver,
  setuptools,
}:

let
  instrument-hooks = fetchFromGitHub {
    hash = "sha256-JTSH4wOpOGJ97iV6sagiRUu8d3sKM2NJRXcB3NmozNQ=";
    owner = "CodSpeedHQ";
    repo = "instrument-hooks";
    rev = "b003e5024d61cfb784d6ac6f3ffd7d61bf7b9ec9";
  };
in

buildPythonPackage rec {
  pname = "pytest-codspeed";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "CodSpeedHQ";
    repo = "pytest-codspeed";
    tag = "v${version}";
    hash = "sha256-MrdMUTNXRatGNsfw7Ghp/PIXPnocEgEMBjAwML/tMos=";
  };

  postPatch = ''
    pushd src/pytest_codspeed/instruments/hooks
    rmdir instrument-hooks
    ln -nsf ${instrument-hooks} instrument-hooks
    popd
  '';

  buildInputs = [ pytest ];

  nativeCheckInputs = [
    semver
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    cffi
    setuptools
  ];

  dependencies = [
    cffi
    rich
  ];

  optional-dependencies = {
    compat = [
      pytest-benchmark
      pytest-xdist
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pytest_codspeed" ];

  meta = {
    description = "Pytest plugin to create CodSpeed benchmarks";
    homepage = "https://github.com/CodSpeedHQ/pytest-codspeed";
    changelog = "https://github.com/CodSpeedHQ/pytest-codspeed/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
