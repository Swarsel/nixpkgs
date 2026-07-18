{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-somafm";
  version = "2.0.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "DC0emxkoWfjGHih2C8nINBFByf521Xf+3Ks4JRxNPLM=";
    pname = "Mopidy-SomaFM";
  };

  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_somafm" ];

  meta = {
    description = "Mopidy extension for playing music from SomaFM";
    homepage = "https://www.mopidy.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.nickhu ];
  };
})
