{
  lib,
  fetchFromGitHub,
  # dependencies
  bitarray,
  buildPythonPackage,
  crc,
  # build-system
  poetry-core,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "airtouch5py";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "danzel";
    repo = "airtouch5py";
    tag = version;
    hash = "sha256-SJ6AVUbdEy0nvpLe39dH/Wc//fDTf0dIvrvVQDUl5eI=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = [
    bitarray
    crc
  ];

  pyproject = true;
  pythonImportsCheck = [ "airtouch5py" ];

  pythonRelaxDeps = [
    "bitarray"
    "crc"
  ];

  meta = {
    description = "Python client for the airtouch 5";
    homepage = "https://github.com/danzel/airtouch5py";
    changelog = "https://github.com/danzel/airtouch5py/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
