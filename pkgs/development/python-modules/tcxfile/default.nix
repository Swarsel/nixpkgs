{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python-dateutil,
  setuptools,
}:

buildPythonPackage rec {
  pname = "tcxfile";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "tcgoetz";
    repo = "tcx";
    tag = version;
    hash = "sha256-d1KSeLlaoyXFU8v+8cKu1+2dU2ywvpWqsHBddo/aBC4=";
  };

  build-system = [
    setuptools
  ];

  dependencies = [
    python-dateutil
  ];

  pyproject = true;
  # cannot run built in tests as they lack data files
  pythonImportsCheck = [ "tcxfile" ];

  meta = {
    description = "Python library to read and write Tcx files";
    homepage = "https://github.com/tcgoetz/tcx";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
  };
}
