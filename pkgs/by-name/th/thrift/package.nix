{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  boost,
  cmake,
  ctestCheckHook,
  flex,
  libevent,
  openssl,
  pkg-config,
  python3,
  zlib,
  static ? stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thrift";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "thrift";
    tag = "v${finalAttrs.version}";
    hash = "sha256-gGAO+D0A/hEoHMm6OvRBc1Mks9y52kfd0q/Sg96pdW4=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    bison
    cmake
    flex
    pkg-config
    (python3.withPackages (
      ps:
      with ps;
      [
        setuptools
        six
      ]
      ++ lib.optionals (!static) [
        twisted
      ]
    ))
  ];

  buildInputs = [
    boost
  ];

  propagatedBuildInputs = [
    libevent
    openssl
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_JAVASCRIPT" false)
    (lib.cmakeBool "BUILD_NODEJS" false)
    (lib.cmakeBool "BUILD_SHARED_LIBS" (!static))
    (lib.cmakeBool "OPENSSL_USE_STATIC_LIBS" static)

    # FIXME: Fails to link in static mode with undefined reference to
    # `boost::unit_test::unit_test_main(bool (*)(), int, char**)'
    (lib.cmakeBool "BUILD_TESTING" (!static))
  ];

  preConfigure = ''
    export PY_PREFIX=$out
  '';

  doCheck = !static;
  nativeCheckInputs = [ ctestCheckHook ];

  disabledTests = [
    "UnitTests" # getaddrinfo() -> -3; Temporary failure in name resolution
    "python_test" # many failures about python 2 or network things
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # Tests that hang up in the Darwin sandbox
    "SecurityTest"
    "SecurityFromBufferTest"
    "PythonThriftTNonblockingServer"

    # fails on hydra, passes locally
    "concurrency_test"

    # Tests that fail in the Darwin sandbox when trying to use network
    "UnitTests"
    "TInterruptTest"
    "TServerIntegrationTest"
    "processor"
    "processor_test"
    "TNonblockingServerTest"
    "TNonblockingSSLServerTest"
    "StressTest"
    "StressTestConcurrent"
    "StressTestNonBlocking"
  ];

  enableParallelChecking = false;
  # Workaround to make the Python wrapper not drop this package:
  # pythonFull.buildEnv.override { extraLibs = [ thrift ]; }
  pythonPath = [ ];

  meta = {
    description = "Library for scalable cross-language services";
    homepage = "https://thrift.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "thrift";
  };
})
