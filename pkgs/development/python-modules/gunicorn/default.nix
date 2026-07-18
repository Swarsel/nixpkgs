{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # optional-dependencies
  eventlet,
  gevent,
  # dependencies
  packaging,
  pytest-cov-stub,
  pytestCheckHook,
  setproctitle,
  # build-system
  setuptools,
  tornado,
}:

buildPythonPackage rec {
  pname = "gunicorn";
  version = "23.0.0";

  src = fetchFromGitHub {
    owner = "benoitc";
    repo = "gunicorn";
    tag = version;
    hash = "sha256-Dq/mrQwo3II6DBvYfD1FHsKHaIlyHlJCZ+ZyrM4Efe0=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];
  dependencies = [ packaging ];

  optional-dependencies = {
    eventlet = [ eventlet ];
    gevent = [ gevent ];
    gthread = [ ];
    setproctitle = [ setproctitle ];
    tornado = [ tornado ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gunicorn" ];

  meta = {
    description = "WSGI HTTP Server for UNIX, fast clients and sleepy applications";
    homepage = "https://github.com/benoitc/gunicorn";
    changelog = "https://github.com/benoitc/gunicorn/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "gunicorn";
  };
}
