{
  lib,
  fetchFromGitHub,
  asyncserial,
  buildPythonPackage,
  jinja2,
  migen,
  numpy,
  # dependencies
  pyserial,
  # tests
  unittestCheckHook,
}:

buildPythonPackage {
  pname = "misoc";
  version = "0.12-unstable-2025-10-03";

  src = fetchFromGitHub {
    owner = "m-labs";
    repo = "misoc";
    rev = "59043e979f78934f2c2f99ac417c65aa0c7be0b9";
    hash = "sha256-dXamAZkLdTC9UeZV6biipsZN4LHO+ZLoXV4LO+L7HTM=";
  };

  nativeCheckInputs = [
    unittestCheckHook
    numpy
  ];

  dependencies = [
    pyserial
    asyncserial
    jinja2
    migen
  ];

  format = "setuptools";
  pythonImportsCheck = [ "misoc" ];

  meta = {
    description = "Original high performance and small footprint system-on-chip based on Migen";
    homepage = "https://github.com/m-labs/misoc";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
}
