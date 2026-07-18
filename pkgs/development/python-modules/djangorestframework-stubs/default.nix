{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  coreapi,
  django-stubs,
  mypy,
  py,
  pytest-mypy-plugins,
  pytestCheckHook,
  requests,
  types-markdown,
  types-pyyaml,
  types-requests,
  typing-extensions,
  uv-build,
}:

buildPythonPackage rec {
  pname = "djangorestframework-stubs";
  version = "3.16.8";

  src = fetchFromGitHub {
    owner = "typeddjango";
    repo = "djangorestframework-stubs";
    tag = version;
    hash = "sha256-I7+XMUB87+bIyQMQZUm5hUTsJ+2wA3F6qyjJQeWeQdo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "uv_build>=0.8.19,<0.10.0" "uv_build"
  '';

  # Upstream recommends mypy > 1.7 which we don't have yet, thus all tests are failing with 3.14.5 and below
  doCheck = false;

  nativeCheckInputs = [
    py
    pytest-mypy-plugins
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ uv-build ];

  dependencies = [
    django-stubs
    requests
    types-pyyaml
    types-requests
    typing-extensions
  ];

  optional-dependencies = {
    compatible-mypy = [ mypy ] ++ django-stubs.optional-dependencies.compatible-mypy;
    coreapi = [ coreapi ];
    markdown = [ types-markdown ];
  };

  pyproject = true;
  pythonImportsCheck = [ "rest_framework-stubs" ];

  meta = {
    description = "PEP-484 stubs for Django REST Framework";
    homepage = "https://github.com/typeddjango/djangorestframework-stubs";
    changelog = "https://github.com/typeddjango/djangorestframework-stubs/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
