{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  # optional dependencies
  confluent-kafka,
  # native dependencies
  cyrus_sasl,
  # dependencies
  jsonpickle,
  # test
  myst-docutils,
  openssl,
  pkg-config,
  prometheus-client,
  protobuf,
  pytest-benchmark,
  pytestCheckHook,
  pythonAtLeast,
  rustPlatform,
}:

buildPythonPackage rec {
  pname = "bytewax";
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "bytewax";
    repo = "bytewax";
    tag = "v${version}";
    hash = "sha256-O5q1Jd3AMUaQwfQM249CUnkjqEkXybxtM9SOISoULZk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    rustPlatform.maturinBuildHook
    rustPlatform.cargoSetupHook
  ];

  buildInputs = [
    openssl
    cyrus_sasl
    protobuf
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  nativeCheckInputs = [
    myst-docutils
    pytestCheckHook
    pytest-benchmark
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export PY_IGNORE_IMPORTMISMATCH=1
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-TTB1//Xza47rnfvlIs9qMvwHPj/U3w2cGTmWrEokriQ=";
  };

  dependencies = [
    jsonpickle
    prometheus-client
  ];

  # error: the configured Python interpreter version (3.13) is newer than PyO3's maximum supported version (3.12)
  disabled = pythonAtLeast "3.13";

  disabledTestPaths = [
    # dependens on an old myst-docutils version
    "docs"
  ];

  dontUseCmakeConfigure = true;

  enabledTestPaths = [
    "pytests"
  ];

  optional-dependencies = {
    kafka = [ confluent-kafka ];
  };

  pyproject = true;

  pytestFlags = [
    "--benchmark-disable"
  ];

  pythonImportsCheck = [ "bytewax" ];

  meta = {
    description = "Python Stream Processing";
    homepage = "https://github.com/bytewax/bytewax";
    changelog = "https://github.com/bytewax/bytewax/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      mslingsby
      kfollesdal
    ];
  };
}
