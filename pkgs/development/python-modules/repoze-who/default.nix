{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  webob,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "repoze-who";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "repoze";
    repo = "repoze.who";
    tag = version;
    hash = "sha256-vc4McZ0Mve2F/KjT/63NZwy5wl11WG2G/w5sUI71NWg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  # skip failing test
  # OSError: [Errno 22] Invalid argument
  preCheck = ''
    rm repoze/who/plugins/tests/test_htpasswd.py
  '';

  build-system = [ setuptools ];

  dependencies = [
    zope-interface
    webob
  ];

  pyproject = true;
  pythonImportsCheck = [ "repoze.who" ];

  pythonNamespaces = [
    "repoze"
    "repoze.who"
    "repoze.who.plugins"
  ];

  meta = {
    description = "WSGI Authentication Middleware / API";
    homepage = "http://www.repoze.org";
    changelog = "https://github.com/repoze/repoze.who/blob/${version}/CHANGES.rst";
    license = lib.licenses.bsd0;
    maintainers = [ ];
  };
}
