{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  cython,
  deprecated,
  distutils,
  eventlet,
  geomet,
  gevent,
  gremlinpython,
  iana-etc,
  libev,
  libredirect,
  pytestCheckHook,
  pytz,
  pyyaml,
  scales,
  setuptools,
  sure,
  tomli,
  twisted,
}:

buildPythonPackage (finalAttrs: {
  pname = "cassandra-driver";
  version = "3.30.0";

  src = fetchFromGitHub {
    owner = "apache";
    repo = "cassandra-python-driver";
    tag = finalAttrs.version;
    hash = "sha256-4ElOiADaldT/TyLqg/5ijFk9Ygb3GEF37P2d8WdAxkw=";
  };

  buildInputs = [ libev ];
  # This is used to determine the version of cython that can be used
  env.CASS_DRIVER_ALLOWED_CYTHON_VERSION = cython.version;

  preBuild = ''
    export CASS_DRIVER_BUILD_CONCURRENCY=$NIX_BUILD_CORES
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytz
    pyyaml
    sure
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  # Make /etc/protocols accessible to allow socket.getprotobyname('tcp') in sandbox,
  # also /etc/resolv.conf is referenced by some tests
  preCheck =
    (lib.optionalString stdenv.hostPlatform.isLinux ''
      echo "nameserver 127.0.0.1" > resolv.conf
      export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)
      export LD_PRELOAD=${libredirect}/lib/libredirect.so
    '')
    + ''
      # increase tolerance for time-based test
      substituteInPlace tests/unit/io/utils.py --replace 'delta=.15' 'delta=.3'

      export HOME=$(mktemp -d)
      # cythonize this before we hide the source dir as it references
      # one of its files
      cythonize -i tests/unit/cython/types_testhelper.pyx

      mv cassandra .cassandra.hidden
    '';

  postCheck = ''
    unset NIX_REDIRECTS LD_PRELOAD
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    distutils
    setuptools
    cython
    tomli
  ];

  dependencies = [
    deprecated
    geomet
  ];

  disabledTestPaths = [
    # requires puresasl
    "tests/unit/advanced/test_auth.py"
    # Uses asyncore, which is deprecated in python 3.12+
    "tests/unit/io/test_asyncorereactor.py"
  ];

  disabledTests = [
    # doesn't seem to be intended to be run directly
    "_PoolTests"
    # attempts to make connection to localhost
    "test_connection_initialization"
    # time-sensitive
    "test_nts_token_performance"
    "test_empty_connections"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin) [
    # AssertionError: [(1773409714.980824, <cassandra.connection.Timer object at 0x116cb2870>)] is not false
    "test_timer_cancellation"
  ];

  enabledTestPaths = [ "tests/unit" ];

  optional-dependencies = {
    cle = [ cryptography ];
    eventlet = [ eventlet ];
    gevent = [ gevent ];
    graph = [ gremlinpython ];
    metrics = [ scales ];
    twisted = [ twisted ];
  };

  pyproject = true;
  pythonImportsCheck = [ "cassandra" ];
  pythonRelaxDeps = [ "geomet" ];

  meta = {
    description = "Python client driver for Apache Cassandra";
    homepage = "https://github.com/apache/cassandra-python-driver";
    changelog = "https://github.com/apache/cassandra-python-driver/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ ris ];
  };
})
