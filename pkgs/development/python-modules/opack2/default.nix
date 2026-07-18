{
  lib,
  fetchFromGitHub,
  arrow,
  buildPythonPackage,
  construct,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "opack2";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "doronz88";
    repo = "opack2";
    tag = "v${version}";
    hash = "sha256-7kRR4KOR3Wrya2YE8nL5laXrsnI1lSVZMBEij44J+T0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    arrow
    construct
  ];

  pyproject = true;
  pythonImportsCheck = [ "opack2" ];

  meta = {
    description = "Python library for parsing the opack format";
    homepage = "https://github.com/doronz88/opack2";
    changelog = "https://github.com/doronz88/opack2/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
