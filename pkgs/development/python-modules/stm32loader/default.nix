{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch2,
  # build-system
  flit-core,
  # optional-dependencies
  intelhex,
  # dependencies
  progress,
  pyserial,
  # tests
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "stm32loader";
  version = "0.7.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-QTLSEjdJtDH4GCamnKHN5pEjW41rRtAMXxyZZMM5K3w=";
  };

  patches = [
    # fix build with python 3.12
    # https://github.com/florisla/stm32loader/pull/79
    (fetchpatch2 {
      hash = "sha256-JUEjQWOnzeMA1OELS214OR7+MYUkCKN5lxwsmRoFbfo=";
      url = "https://github.com/florisla/stm32loader/commit/96f59b2984b0d0371b2da0360d6e8d94d0b39a68.patch?full_index=1";
    })
  ];

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    progress
    pyserial
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  enabledTestPaths = [ "tests/unit" ];

  optional-dependencies = {
    hex = [ intelhex ];
  };

  pyproject = true;

  meta = {
    description = "Flash firmware to STM32 microcontrollers in Python";
    homepage = "https://github.com/florisla/stm32loader";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    mainProgram = "stm32loader";
  };
}
