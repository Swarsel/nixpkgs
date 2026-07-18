{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  pythonAtLeast,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "paginate";
  version = "0.5.7";

  src = fetchFromGitHub {
    owner = "Pylons";
    repo = "paginate";
    rev = version;
    hash = "sha256-+zX9uGNWcV4BWbD2lcd1u9zZ4m7CnbsYZnc99HNaF8I=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = lib.optionals (pythonAtLeast "3.12") [
    # https://github.com/Pylons/paginate/issues/19
    "test_wrong_collection"
    "test_unsliceable_sequence3"
  ];

  pyproject = true;
  pythonImportsCheck = [ "paginate" ];

  meta = {
    description = "Python pagination module";
    homepage = "https://github.com/Pylons/paginate";
    changelog = "https://github.com/Pylons/paginate/blob/${src.rev}/CHANGELOG.txt";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
