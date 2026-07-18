{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  ifaddr,
  lxml,
  pytest-cov-stub,
  pytestCheckHook,
  python-dateutil,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "upnpclient";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "flyte";
    repo = "upnpclient";
    tag = finalAttrs.version;
    hash = "sha256-bT7oNCYAKJvhCaSczLWnDAy+ULqhjP+3ZvFnIGAb+Ww=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];

  dependencies = [
    requests
    python-dateutil
    lxml
    ifaddr
  ];

  pyproject = true;
  pythonImportsCheck = [ "upnpclient" ];

  meta = {
    description = "Python 3 library for accessing UPnP devices";
    homepage = "https://github.com/flyte/upnpclient";
    changelog = "https://github.com/flyte/upnpclient/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eana ];
  };
})
