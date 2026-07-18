{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  entry-points-txt,
  hatchling,
  headerparser,
  jsonschema,
  packaging,
  pytest-cov-stub,
  pytestCheckHook,
  readme-renderer,
  setuptools,
  wheel-filename,
}:

buildPythonPackage rec {
  pname = "wheel-inspect";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "wheel-inspect";
    tag = "v${version}";
    hash = "sha256-yECgJLShCLiEyZmw9azNP5lwLeas10AfRu/RVMQGejg=";
  };

  nativeCheckInputs = [
    setuptools
    pytestCheckHook
    pytest-cov-stub
    jsonschema
  ];

  build-system = [ hatchling ];

  dependencies = [
    attrs
    entry-points-txt
    headerparser
    packaging
    readme-renderer
    wheel-filename
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::DeprecationWarning"
  ];

  pythonImportsCheck = [ "wheel_inspect" ];

  pythonRelaxDeps = [
    "entry-points-txt"
    "headerparser"
  ];

  meta = {
    description = "Extract information from wheels";
    homepage = "https://github.com/jwodder/wheel-inspect";
    changelog = "https://github.com/wheelodex/wheel-inspect/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ayazhafiz ];
    mainProgram = "wheel2json";
  };
}
