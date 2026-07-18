{
  lib,
  buildPythonPackage,
  calver,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

let
  self = buildPythonPackage rec {
    pname = "trove-classifiers";
    version = "2026.5.20.19";

    src = fetchPypi {
      inherit version;
      hash = "sha256-bmEZk5h8qTJpaK1wRScz2t0xRxWZ05iWBFsolwqbuB4=";
      pname = "trove_classifiers";
    };

    postPatch = ''
      substituteInPlace tests/test_cli.py \
        --replace-fail "BINDIR = Path(sys.executable).parent" "BINDIR = '$out/bin'"
    '';

    doCheck = false; # avoid infinite recursion with hatchling
    nativeCheckInputs = [ pytestCheckHook ];

    build-system = [
      calver
      setuptools
    ];

    pyproject = true;
    pythonImportsCheck = [ "trove_classifiers" ];
    passthru.tests.trove-classifiers = self.overridePythonAttrs { doCheck = true; };

    meta = {
      description = "Canonical source for classifiers on PyPI";
      homepage = "https://github.com/pypa/trove-classifiers";
      changelog = "https://github.com/pypa/trove-classifiers/releases/tag/${version}";
      license = lib.licenses.asl20;
      maintainers = with lib.maintainers; [ dotlambda ];
      mainProgram = "trove-classifiers";
    };
  };
in
self
