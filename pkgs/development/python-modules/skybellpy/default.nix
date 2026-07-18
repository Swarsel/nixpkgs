{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorlog,
  pytest-sugar,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  requests-mock,
  setuptools,
}:

buildPythonPackage rec {
  pname = "skybellpy";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "MisterWil";
    repo = "skybellpy";
    tag = "v${version}";
    hash = "sha256-/+9KYxXYTN0T6PoccAA/pwdwWqOzCSZdNxj6xi6oG74=";
  };

  nativeCheckInputs = [
    pytest-sugar
    pytest-timeout
    pytestCheckHook
    requests-mock
  ];

  build-system = [ setuptools ];

  dependencies = [
    colorlog
    requests
  ];

  # Still uses distrutils, https://github.com/MisterWil/skybellpy/issues/22
  disabled = pythonAtLeast "3.12";
  pyproject = true;
  pythonImportsCheck = [ "skybellpy" ];

  meta = {
    description = "Python wrapper for the Skybell alarm API";
    homepage = "https://github.com/MisterWil/skybellpy";
    changelog = "https://github.com/MisterWil/skybellpy/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "skybellpy";
  };
}
