{
  lib,
  # dependencies
  brotlicffi,
  buildPythonPackage,
  decorator,
  fetchPypi,
  flasgger,
  flask,
  gevent,
  greenlet,
  # optional-dependencies
  gunicorn,
  # tests
  pytestCheckHook,
  # build-system
  setuptools,
  six,
  werkzeug,
}:

buildPythonPackage rec {
  pname = "httpbin";
  version = "0.10.2";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-YyFIaYJhyGhOotK2JM3qhFtAKx/pFzbonfiGQIxjF6k=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    brotlicffi
    decorator
    flask
    flasgger
    greenlet
    six
    werkzeug
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  disabledTests = [
    # Tests seems to be outdated
    "test_anything"
    "test_get"
    "test_redirect_n_equals_to_1"
    "test_redirect_n_higher_than_1"
    "test_redirect_to_post"
    "test_relative_redirect_n_equals_to_1"
    "test_relative_redirect_n_higher_than_1"
  ];

  optional-dependencies = {
    mainapp = [
      gunicorn
      gevent
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "httpbin" ];
  pythonRelaxDeps = [ "greenlet" ];

  meta = {
    description = "HTTP Request and Response Service";
    homepage = "https://github.com/psf/httpbin";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
