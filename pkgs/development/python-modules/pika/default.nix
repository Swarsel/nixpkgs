{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  gevent,
  mock,
  # tests
  nose2,
  # build-system
  setuptools,
  tornado,
  twisted,
}:

buildPythonPackage rec {
  pname = "pika";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "pika";
    repo = "pika";
    tag = version;
    hash = "sha256-60Z+y3YXazUghfnOy4e7HzM18iju5m5OEt4I3Wg6ty4=";
  };

  postPatch = ''
    # don't stop at first test failure
    # don't run acceptance tests because they access the network
    # don't report test coverage
    substituteInPlace nose2.cfg \
      --replace "stop = 1" "stop = 0" \
      --replace "tests=tests/unit,tests/acceptance" "tests=tests/unit" \
      --replace "with-coverage = 1" "with-coverage = 0"
  '';

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    gevent
    tornado
    twisted
  ];

  doCheck = false; # tests require rabbitmq instance, unsure how to skip

  nativeCheckInputs = [
    nose2
    mock
  ];

  checkPhase = ''
    runHook preCheck

    PIKA_TEST_TLS=true nose2 -v

    runHook postCheck
  '';

  pyproject = true;

  meta = {
    description = "Pure-Python implementation of the AMQP 0-9-1 protocol";
    homepage = "https://pika.readthedocs.org";
    changelog = "https://github.com/pika/pika/releases/tag/${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    downloadPage = "https://github.com/pika/pika";
  };
}
