{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  jsonschema,
  nix-update-script,
  pykwalify,
  pytest-cov-stub,
  pytestCheckHook,
  requests,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cffconvert";
  version = "2.0.0-unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "citation-file-format";
    repo = "cffconvert";
    rev = "b6045d78aac9e02b039703b030588d54d53262ac";
    hash = "sha256-zgH9q/Jj/AFoTqi9GJQognngIKtzPvYSWJWVsBdL6xg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];

  dependencies = [
    click
    requests
    ruamel-yaml
    pykwalify
    jsonschema
  ];

  disabledTestPaths = [
    # requires network access
    "tests/cli/test_rawify_url.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "cffconvert" ];

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Command line program to validate and convert CITATION.cff files";
    homepage = "https://github.com/citation-file-format/cffconvert";
    changelog = "https://github.com/citation-file-format/cffconvert/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "cffconvert";
  };
}
