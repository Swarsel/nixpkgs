{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-examples,
  pytest-mock,
  pytestCheckHook,
  python-dotenv,
}:

let
  self = buildPythonPackage rec {
    pname = "pydantic-settings";
    version = "2.12.0";

    src = fetchFromGitHub {
      owner = "pydantic";
      repo = "pydantic-settings";
      tag = "v${version}";
      hash = "sha256-5SfF5Wfs/iLThd5xL/5C+qOQfg8s/9WUCSc5qag7CY0=";
    };

    # ruff is a dependency of pytest-examples which is required to run the tests.
    # We do not want all of the downstream packages that depend on pydantic-settings to also depend on ruff.
    doCheck = false;

    nativeCheckInputs = [
      pytestCheckHook
      pytest-examples
      pytest-mock
    ];

    preCheck = ''
      export HOME=$TMPDIR
    '';

    build-system = [ hatchling ];

    dependencies = [
      pydantic
      python-dotenv
    ];

    disabledTests = [
      # expected to fail
      "test_docs_examples[docs/index.md:212-246]"
    ];

    pyproject = true;
    pythonImportsCheck = [ "pydantic_settings" ];

    passthru.tests = {
      pytest = self.overridePythonAttrs { doCheck = true; };
    };

    meta = {
      description = "Settings management using pydantic";
      homepage = "https://github.com/pydantic/pydantic-settings";
      license = lib.licenses.mit;
      maintainers = [ ];
      broken = lib.versionOlder pydantic.version "2.0.0";
    };
  };
in
self
