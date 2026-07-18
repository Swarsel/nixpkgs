{
  lib,
  buildPythonPackage,
  distro,
  fetchPypi,
  fixtures,
  httplib2,
  lazr-uri,
  oauthlib,
  pytestCheckHook,
  setuptools,
  six,
  wadllib,
  wsgi-intercept,
}:

buildPythonPackage rec {
  pname = "lazr-restfulclient";
  version = "0.14.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Q/EqHTlIRjsUYgOMR7Qp3LXkLgun8uFlEbArpdKt/9s=";
    pname = "lazr.restfulclient";
  };

  # E   ModuleNotFoundError: No module named 'lazr.uri'
  doCheck = false;

  nativeCheckInputs = [
    fixtures
    lazr-uri
    pytestCheckHook
    wsgi-intercept
  ];

  build-system = [ setuptools ];

  dependencies = [
    distro
    httplib2
    oauthlib
    setuptools
    six
    wadllib
  ];

  pyproject = true;
  pythonImportsCheck = [ "lazr.restfulclient" ];
  pythonNamespaces = [ "lazr" ];

  meta = {
    description = "Programmable client library that takes advantage of the commonalities among";
    homepage = "https://launchpad.net/lazr.restfulclient";
    changelog = "https://git.launchpad.net/lazr.restfulclient/tree/NEWS.rst?h=${version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
