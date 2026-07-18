{
  lib,
  fetchFromGitHub,
  aiocoap,
  buildPythonPackage,
  pycryptodomex,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "aioairctrl";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "kongo09";
    repo = "aioairctrl";
    tag = "v${version}";
    hash = "sha256-Ea5OMbpwDubhnpY5K0CVXZneEGtNWkqkQQ7JwVa/JNU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    aiocoap
    pycryptodomex
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioairctrl" ];

  meta = {
    description = "Library for controlling Philips air purifiers (using encrypted CoAP)";
    homepage = "https://github.com/kongo09/aioairctrl";
    changelog = "https://github.com/kongo09/aioairctrl/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ justinas ];
  };
}
