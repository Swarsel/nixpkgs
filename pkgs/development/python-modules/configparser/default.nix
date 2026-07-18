{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "configparser";
  version = "7.2.0";

  src = fetchFromGitHub {
    owner = "jaraco";
    repo = "configparser";
    tag = "v${version}";
    hash = "sha256-ZPoHnmD0YjY3+dUW1NKDJjNOVrUFNOjQyMqamOsS2RQ=";
  };

  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Updated configparser from Python 3.7 for Python 2.6+";
    homepage = "https://github.com/jaraco/configparser";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
