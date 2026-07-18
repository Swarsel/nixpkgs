{
  lib,
  buildPythonPackage,
  # install_requires
  dnspython,
  eventlet,
  fetchPypi,
  kombu,
  mock,
  packaging,
  path,
  pyyaml,
  requests,
  setuptools,
  six,
  werkzeug,
  wrapt,
}:

buildPythonPackage rec {
  pname = "nameko";
  version = "2.14.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-J1NXi7Tca5KAGuozTSkwuX37dEhucF7daRmDBqlGjIg=";
  };

  postPatch = ''
    substituteInPlace setup.py --replace-fail "path.py" "path"
  '';

  # tests depend on RabbitMQ being installed - https://nameko.readthedocs.io/en/stable/contributing.html#running-the-tests
  # and most of the tests are network based
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    dnspython
    eventlet
    kombu
    mock
    packaging
    path
    pyyaml
    requests
    setuptools
    six
    werkzeug
    wrapt
  ];

  pyproject = true;
  pythonImportsCheck = [ "nameko" ];

  meta = {
    description = "Microservices framework that lets service developers concentrate on application logic and encourages testability";
    homepage = "https://www.nameko.io/";
    changelog = "https://github.com/nameko/nameko/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ siddharthdhakane ];
    mainProgram = "nameko";
  };
}
