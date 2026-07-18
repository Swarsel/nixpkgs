{
  lib,
  fetchFromGitHub,
  brotli,
  buildPythonPackage,
  cargo,
  execnet,
  jinja2,
  pytest-rerunfailures,
  pytestCheckHook,
  pyzmq,
  redis,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  sqlalchemy,
}:

buildPythonPackage (finalAttrs: {
  pname = "logbook";
  version = "1.9.2";

  src = fetchFromGitHub {
    owner = "getlogbook";
    repo = "logbook";
    tag = finalAttrs.version;
    hash = "sha256-/oaBUIMsDwyxjQU57BpwXQfDMBNSDAI7fqtem/4QqKw=";
  };

  nativeBuildInputs = [
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-rerunfailures
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-xIjcK69rwtE86DfvD9qXEn8MDIvU0Dl+d4Fmw9BUuCM=";
  };

  disabledTests = [
    # Test require Redis instance
    "test_redis_handler"
  ];

  optional-dependencies = {
    all = [
      brotli
      execnet
      jinja2
      pyzmq
      redis
      sqlalchemy
    ];

    compression = [ brotli ];
    execnet = [ execnet ];
    jinja = [ jinja2 ];
    redis = [ redis ];
    sqlalchemy = [ sqlalchemy ];
    zmq = [ pyzmq ];
  };

  pyproject = true;
  pythonImportsCheck = [ "logbook" ];

  meta = {
    description = "Logging replacement for Python";
    homepage = "https://logbook.readthedocs.io/";
    changelog = "https://github.com/getlogbook/logbook/blob/${finalAttrs.src.tag}/CHANGES";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
})
