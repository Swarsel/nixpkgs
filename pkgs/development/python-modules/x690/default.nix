{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  t61codec,
}:

buildPythonPackage rec {
  pname = "x690";
  version = "1.0.0post1";

  src = fetchFromGitHub {
    owner = "exhuma";
    repo = "x690";
    tag = "v${version}";
    hash = "sha256-HNKZq6VfqYAih2SrhGChC2jaQ76dhzKM/Mcr6pVYFE4=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [
    t61codec
  ];

  disabledTests = [
    # AssertionError: "<UnknownType 99 b'abc' TypeClass.APPLICATION/TypeNature.CONSTRUCTED/3>" != "<UnknownType 99 b'abc' application/constructed/3>"
    "test_repr"
  ];

  pyproject = true;
  pythonImportsCheck = [ "x690" ];

  pythonRelaxDeps = [
    "t61codec"
  ];

  meta = {
    description = "Pure Python X.690 implementation";
    homepage = "https://github.com/exhuma/x690";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
