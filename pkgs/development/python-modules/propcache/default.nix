{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  expandvars,
  pytest-codspeed,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "propcache";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "aio-libs";
    repo = "propcache";
    tag = "v${version}";
    hash = "sha256-vn6FSdWEMk6c8Cu1mHyhZyH8ZlFK0kgYK8T7GKLHHwc=";
  };

  postPatch = ''
    substituteInPlace packaging/pep517_backend/_backend.py \
      --replace "Cython ~=" "Cython >="
  '';

  nativeCheckInputs = [
    pytest-codspeed
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    cython
    expandvars
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "propcache" ];

  meta = {
    description = "Fast property caching";
    homepage = "https://github.com/aio-libs/propcache";
    changelog = "https://github.com/aio-libs/propcache/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
