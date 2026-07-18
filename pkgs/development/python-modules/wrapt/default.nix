{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  sphinx-rtd-theme,
  sphinxHook,
}:

buildPythonPackage rec {
  pname = "wrapt";
  version = "1.17.2";

  src = fetchFromGitHub {
    owner = "GrahamDumpleton";
    repo = "wrapt";
    tag = version;
    hash = "sha256-QduT5bncXi4LeI034h5Pqtwybru0QcQIYI7cMchLy7c=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [ ./pytest9-compat.patch ];

  nativeBuildInputs = [
    sphinxHook
    sphinx-rtd-theme
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "wrapt" ];

  meta = {
    description = "Module for decorators, wrappers and monkey patching";
    homepage = "https://github.com/GrahamDumpleton/wrapt";
    license = lib.licenses.bsd2;
    maintainers = [ ];
  };
}
