{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  matplotlib,
  numpy,
  openpyxl,
  pandas,
  poetry-core,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "niapy";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "NiaOrg";
    repo = "NiaPy";
    tag = "v${version}";
    hash = "sha256-5Cxxug/FyucU+MkWXMtH43AembfZ/kj5r8nId5664z8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-xdist
  ];

  build-system = [ poetry-core ];

  dependencies = [
    matplotlib
    numpy
    openpyxl
    pandas
  ];

  pyproject = true;
  pythonImportsCheck = [ "niapy" ];

  pythonRelaxDeps = [
    "numpy"
  ];

  meta = {
    description = "Micro framework for building nature-inspired algorithms";
    homepage = "https://niapy.org/";
    changelog = "https://github.com/NiaOrg/NiaPy/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
