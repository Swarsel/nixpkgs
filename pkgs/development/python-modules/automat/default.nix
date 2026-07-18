{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  pytest-benchmark,
  pytestCheckHook,
  setuptools,
}:

let
  automat = buildPythonPackage rec {
    pname = "automat";
    version = "25.4.16";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-ABdZGlR3Bm6Q0msOaW3cFDuq/Ye1iM+sgQC8a+ljTeA=";
    };

    # escape infinite recursion with twisted
    doCheck = false;

    nativeCheckInputs = [
      pytest-benchmark
      pytestCheckHook
    ];

    build-system = [
      setuptools
      hatch-vcs
    ];

    pyproject = true;
    pytestFlags = [ "--benchmark-disable" ];

    passthru.tests = {
      check = automat.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Self-service finite-state machines for the programmer on the go";
      homepage = "https://github.com/glyph/Automat";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "automat-visualize";
    };
  };
in
automat
