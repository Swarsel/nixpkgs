{
  lib,
  fetchFromGitHub,
  boost,
  buildPythonPackage,
  numpy,
  scipy,
  setuptools,
  simpleitk,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "medpy";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "loli";
    repo = "medpy";
    tag = version;
    hash = "sha256-M46d8qiR3+ioiuRhzIaU5bV1dnfDm819pjn78RYlcG0=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  preCheck = ''
    rm -r medpy/  # prevent importing from build directory at test time
    rm -r tests/graphcut_  # SIGILL at test time
  '';

  build-system = [ setuptools ];

  dependencies = [
    boost
    numpy
    scipy
    simpleitk
  ];

  pyproject = true;

  pythonImportsCheck = [
    "medpy"
    "medpy.core"
    "medpy.features"
    "medpy.filter"
    "medpy.graphcut"
    "medpy.io"
    "medpy.metric"
    "medpy.utilities"
  ];

  meta = {
    description = "Medical image processing library";
    homepage = "https://loli.github.io/medpy";
    changelog = "https://github.com/loli/medpy/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
