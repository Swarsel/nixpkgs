{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pastedeploy";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "Pylons";
    repo = "pastedeploy";
    tag = version;
    hash = "sha256-yR7UxAeF0fQrbU7tl29GpPeEAc4YcxHdNQWMD67pP3g=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "paste.deploy" ];

  meta = {
    description = "Load, configure, and compose WSGI applications and servers";
    homepage = "https://github.com/Pylons/pastedeploy";
    changelog = "https://github.com/Pylons/pastedeploy/blob/${src.tag}/docs/news.rst";
    license = lib.licenses.mit;
    teams = [ lib.teams.openstack ];
  };
}
