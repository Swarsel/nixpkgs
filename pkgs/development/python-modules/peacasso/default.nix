{
  lib,
  accelerate,
  buildPythonPackage,
  diffusers,
  fastapi,
  fetchPypi,
  ftfy,
  nix-update-script,
  pydantic,
  scipy,
  setuptools,
  setuptools-scm,
  torch,
  transformers,
  typer,
  uvicorn,
}:

buildPythonPackage rec {
  pname = "peacasso";
  version = "0.0.19a0";

  # No releases or tags are available in https://github.com/victordibia/peacasso
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qBoG9FAJs0oZrQ0jShtPZfZPmyUZD30MGXDUfMl5bQk=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    accelerate
    diffusers
    fastapi
    ftfy
    pydantic
    scipy
    torch
    transformers
    typer
    uvicorn
  ];

  pyproject = true;

  pythonImportsCheck = [
    "peacasso"
  ];

  pythonRelaxDeps = [ "diffusers" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "UI tool to help you generate art (and experiment) with multimodal (text, image) AI models (stable diffusion)";
    homepage = "https://github.com/victordibia/peacasso";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "peacasso";
  };
}
