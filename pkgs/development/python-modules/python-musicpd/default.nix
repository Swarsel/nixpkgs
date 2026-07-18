{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-musicpd";
  version = "0.9.2";

  src = fetchPypi {
    inherit version;
    hash = "sha256-RFYIVDTy492sfp68sjO0MFKcHI9Gxt25Ixdu8iiOlTo=";
    pname = "python_musicpd";
  };

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "MPD (Music Player Daemon) client library written in pure Python";
    homepage = "https://gitlab.com/kaliko/python-musicpd";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ apfelkuchen6 ];
  };
}
