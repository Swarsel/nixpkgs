{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-tunein";
  version = "1.1.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "01y1asylscr73yqx071imhrzfzlg07wmqqzkdvpgm6r35marc2li";
    pname = "Mopidy-TuneIn";
  };

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_tunein.tunein" ];

  meta = {
    description = "Mopidy extension for playing music from tunein";
    homepage = "https://github.com/kingosticks/mopidy-tunein";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
