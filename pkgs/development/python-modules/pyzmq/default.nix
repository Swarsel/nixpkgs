{
  lib,
  buildPythonPackage,
  # build-system
  cffi,
  cmake,
  cython,
  fetchPypi,
  isPyPy,
  libsodium,
  ninja,
  packaging,
  pathspec,
  pytest-asyncio,
  # checks
  pytestCheckHook,
  scikit-build-core,
  tornado,
  zeromq,
}:

buildPythonPackage rec {
  pname = "pyzmq";
  version = "27.1.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rAdl49REVa223b9EF9zORg/ECgWXjAjv3ylIBy9ttUA=";
  };

  buildInputs = [
    libsodium
    zeromq
  ];

  nativeCheckInputs = [
    pytestCheckHook
    tornado
    pytest-asyncio
  ];

  preCheck = ''
    rm -r zmq
  '';

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  build-system = [
    cmake
    ninja
    packaging
    pathspec
    scikit-build-core
  ]
  ++ (if isPyPy then [ cffi ] else [ cython ]);

  dependencies = lib.optionals isPyPy [ cffi ];

  disabledTestMarks = [
    "flaky"
  ];

  disabledTests = [
    # Tests hang
    "test_socket"
    "test_monitor"
    # https://github.com/zeromq/pyzmq/issues/1272
    "test_cython"
    # Test fails
    "test_mockable"
    # Issues with the sandbox
    "TestFutureSocket"
    "TestIOLoop"
    "TestPubLog"
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "zmq" ];

  meta = {
    description = "Python bindings for ØMQ";
    homepage = "https://pyzmq.readthedocs.io/";

    license = with lib.licenses; [
      bsd3 # or
      lgpl3Only
    ];

    maintainers = [ ];
  };
}
