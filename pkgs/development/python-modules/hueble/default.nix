{
  lib,
  fetchFromGitHub,
  bleak,
  bleak-retry-connector,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hueble";
  version = "2.2.2";

  src = fetchFromGitHub {
    owner = "flip-dots";
    repo = "HueBLE";
    tag = "v${version}";
    hash = "sha256-ASegu+kssupiJD6IFDAmZk7kl+RVUsTep6Zjs6IhVBI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bleak
    bleak-retry-connector
  ];

  pyproject = true;
  pythonImportsCheck = [ "HueBLE" ];

  meta = {
    description = "Python module for controlling Bluetooth Philips Hue lights";
    homepage = "https://github.com/flip-dots/HueBLE";
    changelog = "https://github.com/flip-dots/HueBLE/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
