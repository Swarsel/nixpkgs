{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyramid,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyramid-multiauth";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "pyramid_multiauth";
    tag = version;
    hash = "sha256-tDQENdM+eeAve3DoU3bXMP4k1hSIQ6FlFNlG+rVYhOc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pyramid ];
  pyproject = true;

  meta = {
    description = "Authentication policy for Pyramid that proxies to a stack of other authentication policies";
    homepage = "https://github.com/mozilla-services/pyramid_multiauth";
    changelog = "https://github.com/mozilla-services/pyramid_multiauth/releases/tag/${version}";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
  };
}
