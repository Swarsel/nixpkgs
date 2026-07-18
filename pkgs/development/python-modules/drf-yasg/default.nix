{
  lib,
  buildPythonPackage,
  datadiff,
  dj-database-url,
  django,
  djangorestframework,
  fetchPypi,
  inflection,
  packaging,
  pytest-django,
  pytestCheckHook,
  pytz,
  pyyaml,
  setuptools,
  setuptools-scm,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "drf-yasg";
  version = "1.21.15";

  src = fetchPypi {
    inherit version;
    hash = "sha256-74aDjE7xDc06wevyvmAcvgKXi5mWccqkNmf3yduWFGg=";
    pname = "drf_yasg";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools-scm ~= 7.0" "setuptools-scm >= 7.0"
  '';

  env.DJANGO_SETTINGS_MODULE = "testproj.settings.local";
  # a lot of libraries are missing
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    datadiff
    dj-database-url
  ];

  preCheck = ''
    cd testproj
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    django
    djangorestframework
    inflection
    packaging
    pytz
    pyyaml
    uritemplate
  ];

  pyproject = true;
  pythonImportsCheck = [ "drf_yasg" ];

  meta = {
    description = "Generation of Swagger/OpenAPI schemas for Django REST Framework";
    homepage = "https://github.com/axnsan12/drf-yasg";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
