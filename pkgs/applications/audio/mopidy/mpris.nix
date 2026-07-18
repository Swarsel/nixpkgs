{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-mpris";
  version = "3.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-rHQgNIyludTEL7RDC8dIpyGTMOt1Tazn6i/orKlSP4U=";
    pname = "Mopidy-MPRIS";
  };

  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.pydbus
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_mpris" ];

  meta = {
    description = "Mopidy extension for controlling Mopidy through D-Bus using the MPRIS specification";
    homepage = "https://www.mopidy.com/";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.nickhu ];
  };
})
