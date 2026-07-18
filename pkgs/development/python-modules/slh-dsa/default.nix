{
  lib,
  buildPythonPackage,
  fetchPypi,
  mypy,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "slh-dsa";
  version = "0.2.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-p4eWMVayOFiEjFtlnsmmtH6HMfcIeYIpgdfjuB4mmAY=";
    pname = "slh_dsa";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"mypy>=1.10.1",' ""
  '';

  env.SLHDSA_BUILD_OPTIMIZED = "1";

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [
    setuptools
    mypy
  ];

  pyproject = true;
  pythonImportsCheck = [ "slhdsa" ];

  meta = {
    description = "Pure Python implementation of the SLH-DSA algorithm";
    homepage = "https://github.com/colinxu2020/slhdsa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
  };
}
