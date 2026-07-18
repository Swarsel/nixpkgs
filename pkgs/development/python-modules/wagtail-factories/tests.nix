{
  buildPythonPackage,
  django-pattern-library,
  pytest-django,
  pytestCheckHook,
  wagtail,
  wagtail-factories,
}:

buildPythonPackage {
  inherit (wagtail-factories) src version;
  pname = "wagtail-factories-tests";

  checkInputs = [
    django-pattern-library
    pytestCheckHook
    pytest-django
    wagtail
    wagtail-factories
  ];

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
