{
  lib,
  stdenv,
  fetchFromGitHub,
  ahocorapy,
  buildPythonPackage,
  construct,
  pybluez,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "beacontools";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "citruz";
    repo = "beacontools";
    tag = "v${version}";
    hash = "sha256-3a/HDssOqIfReSijRvmiXwuZjvWLJfDaDyUdA2vv/jA=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    ahocorapy
    construct
  ];

  optional-dependencies = {
    scan = lib.optionals stdenv.hostPlatform.isLinux [ pybluez ];
  };

  pyproject = true;
  pythonImportsCheck = [ "beacontools" ];

  pythonRelaxDeps = [
    "ahocorapy"
  ];

  meta = {
    description = "Python library for working with various types of Bluetooth LE Beacons";
    homepage = "https://github.com/citruz/beacontools";
    changelog = "https://github.com/citruz/beacontools/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
