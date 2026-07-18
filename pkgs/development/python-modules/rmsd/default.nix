{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  pytestCheckHook,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rmsd";
  version = "1.6.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-blEDbbrGtOz067Jq24QMBU5P8otmBwnUl8Tpjvc7TLo=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    scipy
  ];

  pyproject = true;
  pythonImportsCheck = [ "rmsd" ];

  meta = {
    description = "Calculate root-mean-square deviation (RMSD) between two sets of cartesian coordinates";
    homepage = "https://github.com/charnley/rmsd";
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      sheepforce
      markuskowa
    ];

    platforms = lib.platforms.linux;
    mainProgram = "calculate_rmsd";
  };
}
