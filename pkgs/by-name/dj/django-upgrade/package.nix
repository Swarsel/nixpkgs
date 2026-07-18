{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "django-upgrade";
  version = "1.31.1";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "django-upgrade";
    tag = finalAttrs.version;
    hash = "sha256-6x1542ieT+G/r3IiCw4aLePY3HLzpycI7FOBqHm1fmE=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  build-system = [ python3Packages.setuptools ];
  dependencies = [ python3Packages.tokenize-rt ];
  pyproject = true;
  pythonImportsCheck = [ "django_upgrade" ];

  meta = {
    description = "Automatically upgrade your Django projects";
    homepage = "https://github.com/adamchainz/django-upgrade";
    changelog = "https://github.com/adamchainz/django-upgrade/blob/${finalAttrs.version}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.kalekseev ];
    mainProgram = "django-upgrade";
  };
})
