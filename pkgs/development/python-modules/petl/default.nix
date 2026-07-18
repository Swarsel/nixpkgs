{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "petl";
  version = "1.7.19";

  src = fetchFromGitHub {
    owner = "petl-developers";
    repo = "petl";
    tag = "v${version}";
    hash = "sha256-xRNQ4QwTw96kVYzfBiMZcsrPugGFiiRblV1nZ8pAFLY=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;

  pythonImportsCheck = [
    "petl"
  ];

  meta = {
    description = "Python package for extracting, transforming and loading tables of data";
    homepage = "https://github.com/petl-developers/petl";
    changelog = "https://github.com/petl-developers/petl/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      alapshin
    ];

    mainProgram = "petl";
  };
}
