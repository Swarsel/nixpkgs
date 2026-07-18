{
  lib,
  build,
  buildPythonPackage,
  fetchPypi,
  id,
  keyring,
  packaging,
  pkginfo,
  pretend,
  pytest-socket,
  pytestCheckHook,
  readme-renderer,
  requests,
  requests-toolbelt,
  rfc3986,
  rich,
  setuptools,
  setuptools-scm,
  urllib3,
}:

buildPythonPackage rec {
  pname = "twine";
  version = "6.2.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-5e0NL9cMmVl3Dc5RyPOciUXFdOGBc6e4GALatRtLdc8=";
  };

  nativeCheckInputs = [
    build
    pretend
    pytest-socket
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    id
    keyring
    packaging
    pkginfo
    readme-renderer
    requests
    requests-toolbelt
    rfc3986
    rich
    urllib3
  ];

  pyproject = true;
  pythonImportsCheck = [ "twine" ];

  meta = {
    description = "Collection of utilities for interacting with PyPI";
    homepage = "https://github.com/pypa/twine";
    license = lib.licenses.asl20;
    mainProgram = "twine";
  };
}
