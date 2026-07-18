{
  lib,
  stdenv,
  buildPythonPackage,
  ddt,
  docutils,
  fetchPypi,
  imageio,
  matplotlib,
  numpy,
  setuptools,
}:
let
  pname = "color-matcher";
  version = "0.6.0";
in
buildPythonPackage {
  inherit pname version;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-e6igB4LD5eWTHdp7H7nFcqzoLeDGyXZUQyt8/gqnSEM=";
  };

  postPatch = ''
    ln -s */requires.txt requirements.txt
  '';

  # Some tests are broken and many require internet access
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
    imageio
    docutils
    ddt
    matplotlib
  ];

  pyproject = true;

  meta = {
    description = "Package enabling color transfer across images";
    homepage = "https://github.com/hahnec/color-matcher";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kilyanni ];
    # requires py2app which is not packaged for darwin
    broken = stdenv.hostPlatform.isDarwin;
  };
}
