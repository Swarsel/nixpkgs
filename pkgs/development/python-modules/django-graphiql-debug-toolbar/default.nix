{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  django-debug-toolbar,
  fetchpatch,
  graphene-django,
  # build-system
  poetry-core,
  # tests
  pytest-django,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "django-graphiql-debug-toolbar";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "flavors";
    repo = "django-graphiql-debug-toolbar";
    rev = version;
    sha256 = "0fikr7xl786jqfkjdifymqpqnxy4qj8g3nlkgfm24wwq0za719dw";
  };

  patches = [
    # Add compatibility for py-django-debug-toolbar >= 4.4.6
    # https://github.com/flavors/django-graphiql-debug-toolbar/pull/27
    (fetchpatch {
      hash = "sha256-ywTLqXlAxA2DCacrJOqmB7jSzfpeuGTX2ETu0fKmhq4=";
      url = "https://github.com/flavors/django-graphiql-debug-toolbar/commit/2b42fdb1bc40109d9bb0ae1fb4d2163d13904724.patch";
    })
  ];

  doCheck = false; # tests broke with django-debug-toolbar 6.0

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DB_BACKEND=sqlite
    export DB_NAME=:memory:
    export DJANGO_SETTINGS_MODULE=tests.settings
  '';

  build-system = [ poetry-core ];

  dependencies = [
    django
    django-debug-toolbar
    graphene-django
  ];

  pyproject = true;
  pythonImportsCheck = [ "graphiql_debug_toolbar" ];

  meta = {
    description = "Django Debug Toolbar for GraphiQL IDE";
    homepage = "https://github.com/flavors/django-graphiql-debug-toolbar";
    changelog = "https://github.com/flavors/django-graphiql-debug-toolbar/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
