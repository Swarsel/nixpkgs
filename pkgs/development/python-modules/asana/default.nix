{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  pytestCheckHook,
  python-dateutil,
  python-dotenv,
  setuptools,
  six,
  urllib3,
}:

buildPythonPackage (finalAttrs: {
  pname = "asana";
  version = "5.2.4";

  src = fetchFromGitHub {
    owner = "asana";
    repo = "python-asana";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bfq3FKJoZE8edAAFVNYYrLJ8vp44QYboEVsCGsI5WMY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    certifi
    six
    python-dateutil
    python-dotenv
    urllib3
  ];

  disabledTestPaths = [
    # Tests require network access
    "build_tests/"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asana" ];

  meta = {
    description = "Python client library for Asana";
    homepage = "https://github.com/asana/python-asana";
    changelog = "https://github.com/Asana/python-asana/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
