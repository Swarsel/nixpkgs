{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  fastremap,
  numpy,
  pbr,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "connected-components-3d";
  version = "3.22.0";

  src = fetchFromGitHub {
    owner = "seung-lab";
    repo = "connected-components-3d";
    tag = version;
    hash = "sha256-txgQY9k96hFKLrKVLE6ldPdNbSnKOk2FIMrHkRQXlPk=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    scipy
  ]
  ++ optional-dependencies.stack;

  build-system = [
    cython
    numpy
    pbr
    setuptools
  ];

  dependencies = [ numpy ];

  disabledTests = [
    # requires optional dependency crackle-codec (not in nixpkgs)
    "test_connected_components_stack"
  ];

  optional-dependencies = {
    stack = [
      # crackle-codec # not in nixpkgs
      fastremap
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cc3d" ];

  meta = {
    description = "Connected components on discrete and continuous multilabel 3D & 2D images";
    homepage = "https://github.com/seung-lab/connected-components-3d";
    changelog = "https://github.com/seung-lab/connected-components-3d/releases/tag/${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
