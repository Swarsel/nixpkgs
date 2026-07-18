{
  lib,
  fetchFromGitHub,
  # tests
  aiohttp,
  buildPythonPackage,
  # dependencies
  fsspec,
  pytestCheckHook,
  pyyaml,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyyaml-include";
  version = "2.2";

  src = fetchFromGitHub {
    owner = "tanbro";
    repo = "pyyaml-include";
    tag = "v${version}";
    hash = "sha256-nswSYRTZ6LTLSGh78DnrXl3q06Ap1J1IMKOESv1lJoY=";
  };

  nativeCheckInputs = [
    aiohttp
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fsspec
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "yaml_include" ];

  meta = {
    description = "Extending PyYAML with a custom constructor for including YAML files within YAML files";
    homepage = "https://github.com/tanbro/pyyaml-include";
    changelog = "https://github.com/tanbro/pyyaml-include/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
  };
}
