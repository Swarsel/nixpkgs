{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  flit-core,
  psycopg2,
  pydantic,
  pytest-asyncio,
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-ninja";
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "vitalik";
    repo = "django-ninja";
    tag = "v${version}";
    hash = "sha256-nnGIhNGnK7q0nbw7EYJP+xCeS1uiuTrhQxf49dA+Sc8=";
  };

  nativeCheckInputs = [
    psycopg2
    pytest-asyncio
    pytest-django
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    django
    pydantic
  ];

  pyproject = true;

  meta = {
    description = "Web framework for building APIs with Django and Python type hints";
    homepage = "https://django-ninja.dev";
    changelog = "https://github.com/vitalik/django-ninja/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
