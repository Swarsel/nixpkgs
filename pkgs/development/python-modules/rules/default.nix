{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  django,
  djangorestframework,
  python,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "rules";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "dfunckt";
    repo = "django-rules";
    tag = "v${version}";
    hash = "sha256-8Kay2b2uwaI/ml/cPpcj9svoDQI0ptV8tyGeZ76SgZw=";
  };

  nativeCheckInputs = [
    django
    djangorestframework
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests/manage.py test testsuite -v2
    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rules" ];

  meta = {
    description = "Awesome Django authorization, without the database";
    homepage = "https://github.com/dfunckt/django-rules";
    changelog = "https://github.com/dfunckt/django-rules/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
