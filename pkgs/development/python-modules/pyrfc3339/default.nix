{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # dependencies
  pytz,
  # build-system
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pyrfc3339";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "kurtraschke";
    repo = "pyRFC3339";
    tag = "v${version}";
    hash = "sha256-pNtv60ecJ7kceS+dDMuKVCQGARf0SbNVBLqqTIzHDj0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ pytz ];
  pyproject = true;

  pythonImportsCheck = [
    "pyrfc3339"
  ];

  meta = {
    description = "Generate and parse RFC 3339 timestamps";
    homepage = "https://github.com/kurtraschke/pyRFC3339";
    changelog = "https://github.com/kurtraschke/pyRFC3339/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
  };
}
