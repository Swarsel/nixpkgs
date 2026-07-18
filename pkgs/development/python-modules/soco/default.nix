{
  lib,
  fetchFromGitHub,
  appdirs,
  buildPythonPackage,
  graphviz,
  ifaddr,
  lxml,
  mock,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "soco";
  version = "0.31.1";

  src = fetchFromGitHub {
    owner = "SoCo";
    repo = "SoCo";
    tag = "v${version}";
    hash = "sha256-YxIpTFGB82aBvRxfntou2dUZm7T0KSj7yhX3gcdAO7U=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    graphviz
    mock
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    appdirs
    ifaddr
    lxml
    requests
    xmltodict
  ];

  pyproject = true;
  pythonImportsCheck = [ "soco" ];

  meta = {
    description = "CLI and library to control Sonos speakers";
    homepage = "http://python-soco.com/";
    changelog = "https://github.com/SoCo/SoCo/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}
