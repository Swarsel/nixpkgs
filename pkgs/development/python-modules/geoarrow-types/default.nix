{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyarrow,
  pytestCheckHook,
  setuptools-scm,
}:
buildPythonPackage rec {
  pname = "geoarrow-types";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "geoarrow";
    repo = "geoarrow-python";
    tag = "geoarrow-types-${version}";
    hash = "sha256-ciElwh94ukFyFdOBuQWyOUVpn4jBM1RKfxiBCcM+nmE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  checkInputs = [
    pyarrow
  ];

  build-system = [ setuptools-scm ];
  pyproject = true;
  pythonImportsCheck = [ "geoarrow.types" ];
  sourceRoot = "${src.name}/geoarrow-types";

  meta = {
    description = "PyArrow types for geoarrow";
    homepage = "https://github.com/geoarrow/geoarrow-python";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      cpcloud
    ];
  };
}
