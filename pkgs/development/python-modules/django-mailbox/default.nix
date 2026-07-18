{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "django-mailbox";
  version = "4.10.1";

  src = fetchFromGitHub {
    owner = "coddingtonbear";
    repo = "django-mailbox";
    tag = finalAttrs.version;
    hash = "sha256-7CBUnqveTSfdc+8x8sZUqvwYW3vKjZKfOPVWFSo4es0=";
  };

  nativeCheckInputs = [
    pytest-django
    pytestCheckHook
  ];

  preCheck = ''
    substituteInPlace setup.cfg --replace-fail "pytest" "tool:pytest"
    export DJANGO_SETTINGS_MODULE=django_mailbox.tests.settings
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "django_mailbox" ];

  meta = {
    description = "Import mail from POP3, IMAP, local email mailboxes or directly from Postfix or Exim4 into your Django application automatically";
    homepage = "https://github.com/coddingtonbear/django-mailbox";
    changelog = "https://github.com/coddingtonbear/django-mailbox/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kurogeek ];
  };
})
