{
  lib,
  # optional-dependencies
  argcomplete,
  # dependencies
  attrs,
  buildPythonPackage,
  callPackage,
  fetchPypi,
  hypothesis,
  iniconfig,
  mock,
  packaging,
  pluggy,
  pygments,
  requests,
  # build-system
  setuptools,
  setuptools-scm,
  writeText,
  xmlschema,
}:

let
  self = buildPythonPackage rec {
    pname = "pytest";
    version = "7.4.4";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-LPAAWSLGrOSj4uyLQIDrDZdT/ckxB0FTMvUM6eeZQoA=";
    };

    outputs = [
      "out"
      "testout"
    ];

    nativeBuildInputs = [
      setuptools
      setuptools-scm
    ];

    propagatedBuildInputs = [
      iniconfig
      packaging
      pluggy
    ];

    doCheck = false;

    postInstall = ''
      mkdir $testout
      cp -R testing $testout/testing
    '';

    optional-dependencies = {
      testing = [
        argcomplete
        attrs
        hypothesis
        mock
        pygments
        requests
        setuptools
        xmlschema
      ];
    };

    pyproject = true;
    pythonImportsCheck = [ "pytest" ];

    # Remove .pytest_cache when using py.test in a Nix build
    setupHook = writeText "pytest-hook" ''
      pytestcachePhase() {
          find $out -name .pytest_cache -type d -exec rm -rf {} +
      }
      appendToVar preDistPhases pytestcachePhase

      # pytest generates it's own bytecode files to improve assertion messages.
      # These files similar to cpython's bytecode files but are never laoded
      # by python interpreter directly. We remove them for a few reasons:
      # - files are non-deterministic: https://github.com/NixOS/nixpkgs/issues/139292
      #   (file headers are generatedt by pytest directly and contain timestamps)
      # - files are not needed after tests are finished
      pytestRemoveBytecodePhase () {
          # suffix is defined at:
          #    https://github.com/pytest-dev/pytest/blob/7.2.1/src/_pytest/assertion/rewrite.py#L51-L53
          find $out -name "*-pytest-*.py[co]" -delete
      }
      appendToVar preDistPhases pytestRemoveBytecodePhase
    '';

    passthru.tests.pytest = callPackage ./tests.nix { pytest = self; };

    meta = {
      description = "Framework for writing tests";
      homepage = "https://docs.pytest.org";
      changelog = "https://github.com/pytest-dev/pytest/releases/tag/${version}";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        madjar
      ];
    };
  };
in
self
