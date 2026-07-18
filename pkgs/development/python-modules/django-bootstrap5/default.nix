{
  lib,
  fetchFromGitHub,
  beautifulsoup4,
  buildPythonPackage,
  django,
  jinja2,
  pillow,
  pytest-django,
  pytestCheckHook,
  uv-build,
}:

buildPythonPackage rec {
  pname = "django-bootstrap5";
  version = "26.1";

  src = fetchFromGitHub {
    owner = "zostera";
    repo = "django-bootstrap5";
    tag = "v${version}";
    hash = "sha256-kLq1BHN4PKwtAH/TqHn8B697K9Nk5mNMpjUsW5cCrj4=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.9.6,<0.10.0" uv_build
  '';

  nativeCheckInputs = [
    beautifulsoup4
    (django.override { withGdal = true; })
    pillow
    pytest-django
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=tests.app.settings
  '';

  build-system = [ uv-build ];
  dependencies = [ django ];

  disabledTests = [
    # urllib.error.URLError: <urlopen error [Errno -3] Temporary failure in name resolution>
    "test_get_bootstrap_setting"
  ];

  optional-dependencies = {
    jinja = [ jinja2 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "django_bootstrap5" ];

  meta = {
    description = "Bootstrap 5 integration with Django";
    homepage = "https://github.com/zostera/django-bootstrap5";
    changelog = "https://github.com/zostera/django-bootstrap5/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ netali ];
  };
}
