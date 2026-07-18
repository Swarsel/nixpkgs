{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dirty-equals,
  hypothesis,
  inline-snapshot,
  pydantic,
  pytest-benchmark,
  pytest-mock,
  pytest-run-parallel,
  pytest-timeout,
  pytestCheckHook,
  rustPlatform,
  typing-extensions,
  typing-inspection,
}:

let
  pydantic-core = buildPythonPackage rec {
    pname = "pydantic-core";
    version = "2.46.4";

    src = fetchFromGitHub {
      owner = "pydantic";
      repo = "pydantic";
      tag = "core-v${version}";
      hash = "sha256-G4Xo6BF6tOn4g/qG3RNDP3/+lYnCOuw3AB1OrVOGcSA=";
    };

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      rustPlatform.maturinBuildHook
    ];

    # escape infinite recursion with pydantic via inline-snapshot
    doCheck = false;

    nativeCheckInputs = [
      pytestCheckHook
      hypothesis
      inline-snapshot
      pytest-timeout
      dirty-equals
      pytest-benchmark
      pytest-mock
      pytest-run-parallel
      typing-inspection
    ];

    cargoDeps = rustPlatform.fetchCargoVendor {
      inherit
        pname
        version
        src
        sourceRoot
        ;

      hash = "sha256-5L317YTV7/Bc/YJLLzc745oJntiYkcZupdeUxiQwcOU=";
    };

    dependencies = [ typing-extensions ];
    pyproject = true;
    pythonImportsCheck = [ "pydantic_core" ];
    sourceRoot = "${src.name}/pydantic-core";
    passthru.tests.pytest = pydantic-core.overridePythonAttrs { doCheck = true; };

    meta = {
      inherit (pydantic.meta) maintainers;
      description = "Core validation logic for pydantic written in rust";
      homepage = "https://github.com/pydantic/pydantic/tree/main/pydantic-core";
      license = lib.licenses.mit;
    };
  };
in
pydantic-core
