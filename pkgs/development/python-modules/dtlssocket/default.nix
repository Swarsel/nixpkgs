{
  lib,
  autoconf,
  automake,
  buildPythonPackage,
  cython,
  fetchPypi,
  pkg-config,
  setuptools,
}:

buildPythonPackage rec {
  pname = "dtlssocket";
  version = "0.2.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8Gy+Mt+FYtu8y+J0qvJ9J3PoSSqGxBwzSzoKcKUAN88=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
  ];

  # no tests on PyPI, no tags on GitLab
  doCheck = false;

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "DTLSSocket" ];

  meta = {
    description = "Cython wrapper for tinydtls with a Socket like interface";
    homepage = "https://git.fslab.de/jkonra2m/tinydtls-cython";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
