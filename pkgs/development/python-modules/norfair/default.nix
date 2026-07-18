{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  filterpy,
  importlib-metadata,
  motmetrics,
  numpy,
  opencv4,
  poetry-core,
  pytestCheckHook,
  rich,
  scipy,
}:

buildPythonPackage rec {
  pname = "norfair";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "tryolabs";
    repo = "norfair";
    tag = "v${version}";
    hash = "sha256-3a9Z4mbmqmSnOD69RAcKSX6N7vdDU5F/xgsEURnzIR0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    filterpy
    importlib-metadata
    numpy
    rich
    scipy
  ];

  optional-dependencies = {
    metrics = [ motmetrics ];
    video = [ opencv4 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "norfair" ];

  pythonRelaxDeps = [
    "numpy"
    "rich"
  ];

  meta = {
    description = "Lightweight Python library for adding real-time multi-object tracking to any detector";
    homepage = "https://github.com/tryolabs/norfair";
    changelog = "https://github.com/tryolabs/norfair/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fleaz ];
  };
}
