{
  azure-mgmt-cdn,
  azure-mgmt-frontdoor,
  boto3,
  buildPythonPackage,
  django-pattern-library,
  elasticsearch,
  freezegun,
  jinja2,
  msrest,
  python,
  python-dateutil,
  pytz,
  responses,
  wagtail,
  wagtail-factories,
}:

buildPythonPackage {
  inherit (wagtail) src version;
  pname = "wagtail-tests";

  checkInputs = [
    azure-mgmt-cdn
    azure-mgmt-frontdoor
    boto3
    django-pattern-library
    elasticsearch
    freezegun
    jinja2
    msrest
    python-dateutil
    pytz
    responses
    wagtail
    wagtail-factories
  ];

  checkPhase = ''
    export DJANGO_SETTINGS_MODULE=wagtail.test.settings
    ${python.interpreter} -m django test
  '';

  dontBuild = true;
  dontInstall = true;
  pyproject = false;
}
