{
  lib,
  argon2-cffi-bindings,
  buildPythonPackage,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  hypothesis,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "argon2-cffi";
  version = "25.1.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-aUrlzIpC9MTivyyg5k5R4joEDGpReoUHRoPTlZ4TRsE=";
    pname = "argon2_cffi";
  };

  nativeBuildInputs = [
    hatchling
    hatch-vcs
    hatch-fancy-pypi-readme
  ];

  propagatedBuildInputs = [ argon2-cffi-bindings ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "argon2" ];

  meta = {
    description = "Secure Password Hashes for Python";
    homepage = "https://argon2-cffi.readthedocs.io/";
    license = lib.licenses.mit;
  };
}
