{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "naturalsort";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "xolox";
    repo = "python-naturalsort";
    tag = version;
    hash = "sha256-MBb8yCIs9DW77TKiV3qOHidt8/zi9m2dgyfB3xrdg3A=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "natsort" ];

  meta = {
    description = "Simple natural order sorting API for Python that just works";
    homepage = "https://github.com/xolox/python-naturalsort";
    changelog = "https://github.com/xolox/python-naturalsort/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eyjhb ];
  };
}
