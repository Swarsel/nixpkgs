{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  flit-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-context-decorator";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "rixx";
    repo = "django-context-decorator";
    rev = "v${version}";
    hash = "sha256-lNmZDsguOu2+gtMVjbwr709sbLCQOQ1sAePN7UJQbcw=";
  };

  nativeCheckInputs = [
    django
    pytestCheckHook
  ];

  build-system = [ flit-core ];
  pyproject = true;
  pythonImportsCheck = [ "django_context_decorator" ];

  meta = {
    description = "Django @context decorator";
    homepage = "https://github.com/rixx/django-context-decorator";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
