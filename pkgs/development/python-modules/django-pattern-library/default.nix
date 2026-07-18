{
  lib,
  fetchFromGitHub,
  # tests
  beautifulsoup4,
  buildPythonPackage,
  # dependencies
  django,
  markdown,
  mkdocs,
  # build-system
  poetry-core,
  pytest-django,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "django-pattern-library";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "torchbox";
    repo = "django-pattern-library";
    tag = "v${version}";
    hash = "sha256-urK34rlBU5GuEOlUtmJLGv6wlTP5H/RMAkwQu5S2Jbo=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs = [
    django
    pyyaml
    markdown
  ];

  env.DJANGO_SETTINGS_MODULE = "tests.settings.dev";

  nativeCheckInputs = [
    beautifulsoup4
    pytestCheckHook
    pytest-django
    mkdocs # only needed for jinja2, we don't build docs
  ];

  pyproject = true;
  pythonImportsCheck = [ "pattern_library" ];

  meta = {
    description = "UI pattern libraries for Django templates";
    homepage = "https://github.com/torchbox/django-pattern-library/";
    changelog = "https://github.com/torchbox/django-pattern-library/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
