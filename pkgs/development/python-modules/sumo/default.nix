{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  castepxbin,
  colormath,
  h5py,
  importlib-resources,
  matplotlib,
  numpy,
  phonopy,
  pymatgen,
  pytestCheckHook,
  scipy,
  seekpath,
  setuptools,
  spglib,
}:

buildPythonPackage rec {
  pname = "sumo";
  version = "2.3.12";

  src = fetchFromGitHub {
    owner = "SMTG-UCL";
    repo = "sumo";
    tag = "v${version}";
    hash = "sha256-OdoXcdLT/mTkSw/JOrpYjgvUiNLOnBI4avrjrXhzF3U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    spglib
    numpy
    scipy
    h5py
    pymatgen
    phonopy
    matplotlib
    seekpath
    castepxbin
    colormath
    importlib-resources
  ];

  pyproject = true;
  pythonImportsCheck = [ "sumo" ];

  meta = {
    description = "Toolkit for plotting and analysis of ab initio solid-state calculation data";
    homepage = "https://github.com/SMTG-UCL/sumo";
    changelog = "https://github.com/SMTG-Bham/sumo/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
