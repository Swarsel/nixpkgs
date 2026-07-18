{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  numpy,
  # build-system
  pkg-config,
  pytest-benchmark,
  pytest-rerunfailures,
  pytestCheckHook,
  pythonAtLeast,
  rustPlatform,
  rustc,
}:

buildPythonPackage rec {
  pname = "gilknocker";
  version = "0.4.2-post3";

  src = fetchFromGitHub {
    owner = "milesgranger";
    repo = "gilknocker";
    tag = "v${version}";
    hash = "sha256-GSybOILOP0lwxUPB9a8whQvEPS7OdeHcm0pxky7gwkg=";
  };

  nativeBuildInputs =
    with rustPlatform;
    [
      cargoSetupHook
      maturinBuildHook
    ]
    ++ [
      pkg-config
      rustc
    ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
    pytest-benchmark
    pytest-rerunfailures
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-C3rxqmZMSc6SC8bU5VB61x8Xk/crD3o7Nr1xvzv7uqI=";
  };

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    # segfaults
    # https://github.com/milesgranger/gilknocker/issues/35
    "benchmarks"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # depends on an empirically-derived threshold that fails on fast and slow machines.
    # https://github.com/milesgranger/gilknocker/issues/36
    "test_knockknock_some_gil"
  ];

  enabledTestPaths = [
    # skip the benchmarks as they can segfault
    # https://github.com/milesgranger/gilknocker/issues/35
    "tests"
  ];

  pyproject = true;
  pytestFlags = [ "--benchmark-disable" ];

  pythonImportsCheck = [
    "gilknocker"
  ];

  meta = {
    description = "Knock on the Python GIL, determine how busy it is";
    homepage = "https://github.com/milesgranger/gilknocker";
    changelog = "https://github.com/milesgranger/gilknocker/releases/tag/v${version}";

    license = with lib.licenses; [
      mit
      unlicense
    ];

    maintainers = with lib.maintainers; [ daspk04 ];
  };
}
