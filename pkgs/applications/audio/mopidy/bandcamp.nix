{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-bandcamp";
  version = "1.1.5";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-wg9zcOKfZQRhpyA1Cu5wvdwKpmrlcr2m9mrqBHgUXAQ=";
    pname = "Mopidy-Bandcamp";
  };

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.pykka
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_bandcamp" ];

  meta = {
    description = "Mopidy extension for playing music from bandcamp";
    homepage = "https://github.com/impliedchaos/mopidy-bandcamp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ desttinghim ];
  };
})
