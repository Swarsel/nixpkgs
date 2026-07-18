{
  lib,
  fetchurl,
  buildPythonPackage,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "python-linux-procfs";
  version = "0.7.3";

  src = fetchurl {
    url = "https://git.kernel.org/pub/scm/libs/python/python-linux-procfs/python-linux-procfs.git/snapshot/python-linux-procfs-v${version}.tar.gz";
    hash = "sha256-6js8+PBqMwNYSe74zqZP8CZ5nt1ByjCWnex+wBY/LZU=";
  };

  # contains no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ six ];
  pyproject = true;
  pythonImportsCheck = [ "procfs" ];

  meta = {
    description = "Python classes to extract information from the Linux kernel /proc files";
    homepage = "https://git.kernel.org/pub/scm/libs/python/python-linux-procfs/python-linux-procfs.git/";
    license = lib.licenses.gpl2Plus;
    mainProgram = "pflags";
  };
}
