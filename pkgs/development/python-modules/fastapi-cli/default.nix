{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pdm-backend,
  # checks
  pytestCheckHook,
  rich,
  rich-toolkit,
  typer,
  uvicorn,
}:

let
  self = buildPythonPackage rec {
    pname = "fastapi-cli";
    version = "0.0.24";

    src = fetchFromGitHub {
      owner = "fastapi";
      repo = "fastapi-cli";
      tag = version;
      hash = "sha256-LEo8to1mspauTMCQ5Zf6znG0ALqF5XtauPar5bqN6/Q=";
    };

    doCheck = false;

    nativeCheckInputs = [
      pytestCheckHook
      rich
    ]
    ++ optional-dependencies.standard;

    build-system = [ pdm-backend ];

    dependencies = [
      rich-toolkit
      typer
      uvicorn
    ]
    ++ uvicorn.optional-dependencies.standard;

    # coverage
    disabledTests = [ "test_script" ];

    optional-dependencies = {
      standard = [
        uvicorn
        # FIXME package fastapi-cloud-cli
      ]
      ++ uvicorn.optional-dependencies.standard;

      standard-no-fastapi-cloud-cli = [
        uvicorn
      ]
      ++ uvicorn.optional-dependencies.standard;
    };

    pyproject = true;
    pythonImportsCheck = [ "fastapi_cli" ];
    passthru.tests.pytest = self.overridePythonAttrs { doCheck = true; };

    meta = {
      description = "Run and manage FastAPI apps from the command line with FastAPI CLI";
      homepage = "https://github.com/fastapi/fastapi-cli";
      changelog = "https://github.com/fastapi/fastapi-cli/releases/tag/${src.tag}";
      license = lib.licenses.mit;
      maintainers = [ ];
      mainProgram = "fastapi";
      # This package provides a `fastapi`-executable that is in conflict with the one from
      # python3Packages.fastapi. Because this package is primarily used for the purpose of
      # implementing the CLI for python3Packages.fastapi, we reduce the executable's priority
      priority = 10;
    };
  };
in
self
