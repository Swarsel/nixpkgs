{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  hatchling,

  # tests
  pytestCheckHook,
  wcag-contrast-ratio,
}:

let
  pygments = buildPythonPackage (finalAttrs: {
    pname = "pygments";
    version = "2.20.0";

    src = fetchPypi {
      inherit (finalAttrs) pname version;
      hash = "sha256-Z1fNA3aAU/+Z8wOcGjbWwKoLJjQ4/KsXUgswowOoK18=";
    };

    # circular dependencies if enabled by default
    doCheck = false;

    nativeCheckInputs = [
      pytestCheckHook
      wcag-contrast-ratio
    ];

    build-system = [ hatchling ];

    disabledTestPaths = [
      # 5 lines diff, including one nix store path in 20000+ lines
      "tests/examplefiles/bash/ltmain.sh"
    ];

    pyproject = true;
    pythonImportsCheck = [ "pygments" ];

    passthru.tests = {
      check = pygments.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Generic syntax highlighter";
      homepage = "https://pygments.org/";
      changelog = "https://github.com/pygments/pygments/releases/tag/${finalAttrs.version}";
      license = lib.licenses.bsd2;

      maintainers = with lib.maintainers; [
        sigmanificient
        ryand56
      ];

      mainProgram = "pygmentize";
    };
  });
in
pygments
