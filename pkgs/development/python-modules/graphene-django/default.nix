{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  django-filter,
  djangorestframework,
  graphene,
  graphql-core,
  mock,
  promise,
  py,
  pytest-django,
  pytest-random-order,
  pytest7CheckHook,
  text-unidecode,
}:

buildPythonPackage rec {
  pname = "graphene-django";
  version = "3.2.3";

  src = fetchFromGitHub {
    owner = "graphql-python";
    repo = "graphene-django";
    tag = "v${version}";
    hash = "sha256-uMkzgXn3YRgEU46Sv5lg60cvetHir9bv0mzJGDv79DI=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace '"pytest-runner"' ""
  '';

  propagatedBuildInputs = [
    djangorestframework
    graphene
    graphql-core
    django
    promise
    text-unidecode
  ];

  nativeCheckInputs = [
    django-filter
    mock
    py
    pytest-django
    pytest-random-order
    pytest7CheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=examples.django_test_settings
  '';

  disabledTests =
    lib.optionals (lib.versionAtLeast django.version "6.0") [
      "test_global_id_field_explicit"
      "test_global_id_field_implicit"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      # this test touches files in the "/" directory and fails in darwin sandbox
      "test_should_filepath_convert_string"
    ];

  format = "setuptools";

  meta = {
    description = "Integrate GraphQL into your Django project";
    homepage = "https://github.com/graphql-python/graphene-django";
    changelog = "https://github.com/graphql-python/graphene-django/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
