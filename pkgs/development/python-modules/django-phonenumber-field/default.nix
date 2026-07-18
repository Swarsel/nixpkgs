{
  lib,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  django,
  djangorestframework,
  gettext,
  phonenumbers,
  phonenumberslite,
  python,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "django-phonenumber-field";
  version = "8.4.0";

  src = fetchFromGitHub {
    owner = "stefanfoulis";
    repo = "django-phonenumber-field";
    tag = version;
    hash = "sha256-k6r+yy1o7pFJx/9yxI5AbsfRPIhycAc0oXBHyV0GHec=";
  };

  nativeBuildInputs = [ gettext ];

  preBuild = ''
    ${python.interpreter} -m django compilemessages
  '';

  nativeCheckInputs = [
    babel
    djangorestframework
  ];

  checkPhase = ''
    ${python.interpreter} -m django test --settings tests.settings
  '';

  build-system = [ setuptools-scm ];
  # Upstream doesn't put phonenumbers in dependencies but the package doesn't
  # make sense without either of the two optional dependencies. Since, in
  # Nixpkgs, phonenumberslite depends on phonenumbers, add the latter
  # unconditionally.
  dependencies = [ django ] ++ optional-dependencies.phonenumbers;

  optional-dependencies = {
    phonenumbers = [ phonenumbers ];
    phonenumberslite = [ phonenumberslite ];
  };

  pyproject = true;
  pythonImportsCheck = [ "phonenumber_field" ];

  meta = {
    description = "Django model and form field for normalised phone numbers using python-phonenumbers";
    homepage = "https://github.com/stefanfoulis/django-phonenumber-field/";
    changelog = "https://github.com/stefanfoulis/django-phonenumber-field/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sephi ];
  };
}
