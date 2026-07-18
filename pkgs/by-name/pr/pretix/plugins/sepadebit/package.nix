{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django-localflavor,
  # tests
  django-scopes,
  pretix,
  # build-system
  pretix-plugin-build,
  pytest-django,
  pytestCheckHook,
  sepaxml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretix-sepadebit";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "pretix";
    repo = "pretix-sepadebit";
    tag = "v${version}";
    hash = "sha256-Xnp7aic+Xf4wJzJbWqhsfMajT4AOQGQMIGIewJ5B37o=";
  };

  nativeCheckInputs = [
    django-scopes
    pretix
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    export DJANGO_SETTINGS_MODULE=pretix.testutils.settings
  '';

  build-system = [
    pretix-plugin-build
    setuptools
  ];

  dependencies = [
    django-localflavor
    sepaxml
  ];

  disabledTests = [
    # https://github.com/pretix/pretix-sepadebit/issues/69
    "test_mail_context"
    "test_call_mail_context"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pretix_sepadebit"
  ];

  meta = {
    description = "Plugin to receive payments via SEPA direct debit";
    homepage = "https://github.com/pretix/pretix-sepadebit";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bbenno ];
  };
}
