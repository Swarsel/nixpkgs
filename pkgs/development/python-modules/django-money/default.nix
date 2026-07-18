{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  certifi,
  django,
  py-moneyed,
  pytest-cov-stub,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-money";
  version = "3.6.1";

  src = fetchFromGitHub {
    owner = "django-money";
    repo = "django-money";
    tag = finalAttrs.version;
    hash = "sha256-UHqtKav/tot+fSA5ey2R4WdheUWuDBXdOXDgFDXgjLM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-django
    pytest-cov-stub
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    django
    py-moneyed
  ];

  disabledTests = [
    # avoid tests which import mixer, an abandoned library
    "test_mixer_blend"
  ];

  optional-dependencies = {
    exchange = [ certifi ];
  };

  pyproject = true;
  pythonImportsCheck = [ "djmoney" ];

  meta = {
    description = "Money fields for Django forms and models";
    homepage = "https://github.com/django-money/django-money";
    changelog = "https://github.com/django-money/django-money/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
