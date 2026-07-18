{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  packaging,
  twisted,
}:

let
  incremental = buildPythonPackage rec {
    pname = "incremental";
    version = "24.11.0";

    src = fetchFromGitHub {
      owner = "twisted";
      repo = "incremental";
      tag = "incremental-${version}";
      hash = "sha256-GkTCQYGrgCUzizSgKhWeqJ25pfaYA7eUJIHt0q/iO0E=";
    };

    # escape infinite recursion with twisted
    doCheck = false;
    nativeCheckInputs = [ twisted ];

    checkPhase = ''
      trial incremental
    '';

    build-system = [ hatchling ];
    dependencies = [ packaging ];
    pyproject = true;
    pythonImportsCheck = [ "incremental" ];

    passthru.tests = {
      check = incremental.overridePythonAttrs (_: {
        doCheck = true;
      });
    };

    meta = {
      description = "Small library that versions your Python projects";
      homepage = "https://github.com/twisted/incremental";
      changelog = "https://github.com/twisted/incremental/blob/${src.tag}/NEWS.rst";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ dotlambda ];
      mainProgram = "incremental";
    };
  };
in
incremental
