{
  lib,
  fetchFromGitHub,
  bleak,
  buildPythonPackage,
  click,
  pytest-asyncio,
  pytest-mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pykulersky";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "emlove";
    repo = "pykulersky";
    rev = version;
    hash = "sha256-YHGEDAsbQN3sYu7mdVUbb3xX7FMnR0xAhXkvf7Ok7qs=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    click
  ];

  pyproject = true;
  pythonImportsCheck = [ "pykulersky" ];

  meta = {
    description = "Python module to control Brightech Kuler Sky Bluetooth LED devices";
    homepage = "https://github.com/emlove/pykulersky";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pykulersky";
  };
}
