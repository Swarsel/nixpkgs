{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  google-generativeai,
  hass-client,
  jinja2,
  mashumaro,
  openai,
  pyrate-limiter,
  pytestCheckHook,
  python-slugify,
  pyyaml,
  setuptools,
  setuptools-scm,
  synthetic-home,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "home-assistant-datasets";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "allenporter";
    repo = "home-assistant-datasets";
    tag = finalAttrs.version;
    hash = "sha256-csvjbPtsl7/olJAFmiLES9GH7wAZHxOADTpqbcQbM3s=";
  };

  # Tests want to import Home Assistant as a module
  doCheck = false;

  nativeCheckInputs = [
    jinja2
    pytestCheckHook
    python-slugify
    syrupy
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    google-generativeai
    hass-client
    mashumaro
    openai
    pyrate-limiter
    pyyaml
    synthetic-home
  ];

  pyproject = true;
  pythonImportsCheck = [ "home_assistant_datasets" ];

  meta = {
    description = "Collection of datasets for evaluating AI Models in the context of Home Assistant";
    homepage = "https://github.com/allenporter/home-assistant-datasets";
    changelog = "https://github.com/allenporter/home-assistant-datasets/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
