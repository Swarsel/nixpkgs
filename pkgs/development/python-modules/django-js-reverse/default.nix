{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  nodejs,
  packaging,
  python,
  setuptools,
  six,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-js-reverse";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "vintasoftware";
    repo = "django-js-reverse";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XpHQXZuIRl6qBDmbFX/IhHxwrOiMiiiTIF5x3W13kGA=";
  };

  # Js2py is needed for tests but it's unmaintained and insecure
  doCheck = false;

  nativeCheckInputs = [
    nodejs
    six
  ];

  checkPhase = ''
    ${python.interpreter} django_js_reverse/tests/unit_tests.py
  '';

  build-system = [ setuptools ];

  dependencies = [
    django
    packaging
  ];

  pyproject = true;
  pythonImportsCheck = [ "django_js_reverse" ];

  meta = {
    description = "Javascript URL handling for Django";
    homepage = "https://django-js-reverse.readthedocs.io/";
    changelog = "https://github.com/vintasoftware/django-js-reverse/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ambroisie ];
  };
})
