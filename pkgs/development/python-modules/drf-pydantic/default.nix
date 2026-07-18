{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  hatchling,
  pydantic,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "drf-pydantic";
  version = "2.9.1";

  src = fetchFromGitHub {
    owner = "georgebv";
    repo = "drf-pydantic";
    tag = "v${version}";
    hash = "sha256-/dMhKlAMAh63JlhanfSfe15ECMZvtnd1huD8L3Xo2AQ=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ]
  ++ pydantic.optional-dependencies.email;

  build-system = [
    hatchling
  ];

  dependencies = [
    django
    pydantic
    djangorestframework
  ];

  pyproject = true;

  meta = {
    description = "Use pydantic with the Django REST framework";
    homepage = "https://github.com/georgebv/drf-pydantic";
    changelog = "https://github.com/georgebv/drf-pydantic/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kiara ];
  };
}
