{
  lib,
  stdenv,
  buildPythonPackage,
  c-ares,
  cffi,
  cython,
  # for passthru.tests
  dulwich,
  fetchPypi,
  greenlet,
  gunicorn,
  importlib-metadata,
  isPyPy,
  libev,
  libuv,
  pika,
  python,
  setuptools,
  zope-event,
  zope-interface,
}:

buildPythonPackage rec {
  pname = "gevent";
  version = "25.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-rfnNVS3kSk5nVMUf8ueNkZO3+m6rEj25V4ohDmVyNd0=";
  };

  buildInputs = [
    libev
    libuv
    c-ares
  ];

  env = {
    GEVENTSETUP_EMBED = "0";
  }
  // lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  };

  # Bunch of failures.
  doCheck = false;

  build-system = [
    cython
    setuptools
  ]
  ++ lib.optionals (!isPyPy) [ cffi ];

  dependencies = [
    importlib-metadata
    zope-event
    zope-interface
  ]
  ++ lib.optionals (!isPyPy) [ greenlet ];

  pyproject = true;

  pythonImportsCheck = [
    "gevent"
    "gevent.events"
  ];

  passthru.tests = {
    inherit
      dulwich
      gunicorn
      pika
      ;
  }
  // lib.filterAttrs (k: v: lib.hasInfix "gevent" k) python.pkgs;

  meta = {
    description = "Coroutine-based networking library";
    homepage = "http://www.gevent.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bjornfor ];
    platforms = lib.platforms.unix;
  };
}
