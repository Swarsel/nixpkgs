{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pathable";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "p1c2u";
    repo = "pathable";
    tag = version;
    hash = "sha256-DjIn+hXZvx4tKyzQlWPwIxHD8vWy/jEvhdFY6HC+sdo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "pathable" ];

  meta = {
    description = "Library for object-oriented paths";
    homepage = "https://github.com/p1c2u/pathable";
    changelog = "https://github.com/p1c2u/pathable/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
