{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "mplhep-data";
  version = "0.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-v5zcxlw6nOfY8OMHj/ZZ7z/P3hGeYloPcfIbBu2rxMk=";
    pname = "mplhep_data";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "mplhep_data" ];

  meta = {
    description = "Sub-package to hold data (fonts) for mplhep";
    homepage = "https://github.com/scikit-hep/mplhep_data";

    license = with lib.licenses; [
      mit
      gfl
      ofl
    ];

    maintainers = with lib.maintainers; [ veprbl ];
  };
}
