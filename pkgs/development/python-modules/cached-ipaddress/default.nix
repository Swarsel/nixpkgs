{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  poetry-core,
  propcache,
  pytest-codspeed,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cached-ipaddress";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "bdraco";
    repo = "cached-ipaddress";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+A1kMD1L2K+dAWrZJ96qJpx0udRGMWbWApyWtMrE7lk=";
  };

  nativeCheckInputs = [
    pytest-codspeed
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    cython
    poetry-core
    setuptools
  ];

  dependencies = [ propcache ];
  pyproject = true;
  pythonImportsCheck = [ "cached_ipaddress" ];

  meta = {
    description = "Cache construction of ipaddress objects";
    homepage = "https://github.com/bdraco/cached-ipaddress";
    changelog = "https://github.com/bdraco/cached-ipaddress/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
