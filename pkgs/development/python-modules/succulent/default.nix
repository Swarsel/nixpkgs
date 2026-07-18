{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  lxml,
  numpy,
  pandas,
  poetry-core,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "succulent";
  version = "0.4.5";

  src = fetchFromGitHub {
    owner = "firefly-cpp";
    repo = "succulent";
    tag = version;
    hash = "sha256-hoGYpXIrJYT+EZa0iWPDTv+5D4Egdzw4IzCA6rntyvU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    poetry-core
  ];

  dependencies = [
    flask
    lxml
    numpy
    pandas
    pyyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "succulent" ];

  pythonRelaxDeps = [
    "flask"
    "lxml"
    "numpy"
  ];

  meta = {
    description = "Collect POST requests";
    homepage = "https://github.com/firefly-cpp/succulent";
    changelog = "https://github.com/firefly-cpp/succulent/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ firefly-cpp ];
  };
}
