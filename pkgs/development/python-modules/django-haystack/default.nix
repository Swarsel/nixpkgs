{
  lib,
  stdenv,
  buildPythonPackage,
  django,
  elasticsearch,
  fetchPypi,
  geopy,
  packaging,
  pysolr,
  python-dateutil,
  pythonAtLeast,
  requests,
  setuptools,
  setuptools-scm,
  whoosh,
}:

buildPythonPackage rec {
  pname = "django-haystack";
  version = "3.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Eianyc4T4efq2KyD9uh7/vSZbxRu0klx/eeJYRWxxTA=";
    pname = "django_haystack";
  };

  buildInputs = [ django ];
  # tests fail and get stuck on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    geopy
    pysolr
    python-dateutil
    requests
    whoosh
  ]
  ++ optional-dependencies.elasticsearch;

  checkPhase = ''
    runHook preCheck
    python test_haystack/run_tests.py
    runHook postCheck
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ packaging ];

  optional-dependencies = {
    elasticsearch = [ elasticsearch ];
  };

  pyproject = true;

  meta = {
    description = "Pluggable search for Django";
    homepage = "http://haystacksearch.org/";
    changelog = "https://github.com/django-haystack/django-haystack/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
