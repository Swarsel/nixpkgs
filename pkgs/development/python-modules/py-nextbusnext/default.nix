{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "py-nextbusnext";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "ViViDboarder";
    repo = "py_nextbus";
    tag = "v${version}";
    hash = "sha256-zTOP2wj1ZseXYbWGNgehIkgZQkV4u74yjI0mhn35e4E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];

  disabledTestPaths = [
    # tests access the internet
    "acceptance/client_test.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "py_nextbus" ];

  meta = {
    description = "Minimalistic Python client for the NextBus public API";
    homepage = "https://github.com/ViViDboarder/py_nextbus";
    changelog = "https://github.com/ViViDboarder/py_nextbusnext/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
