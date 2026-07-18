{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "scikits-odes-core";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "bmcage";
    repo = "odes";
    tag = "v${version}";
    hash = "sha256-lqkPCVMQIVpZrkNUhYhAlFU71eUAaWwN8v66L7Rz91U=";
  };

  # no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "scikits_odes_core" ];
  sourceRoot = "${src.name}/packages/scikits-odes-core";

  meta = {
    description = "Core support module for scikits-odes";
    homepage = "https://github.com/bmcage/odes/blob/master/packages/scikits-odes-core";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ idontgetoutmuch ];
  };
}
