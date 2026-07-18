{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage rec {
  pname = "fitparse";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "dtcooper";
    repo = "python-fitparse";
    tag = "v${version}";
    hash = "sha256-aO4djG9omc0jogalLitvT5i58cYKXqtvJ5WGBiCv448=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  disabledTests = [
    "test_utils"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fitparse"
  ];

  meta = {
    description = "Python library to parse ANT/Garmin .FIT files";
    homepage = "https://pythonhosted.org/fitparse/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ aciceri ];
  };
}
