{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  dj-database-url,
  dj-email-url,
  django-cache-url,
  flit-core,
  marshmallow,
  pytestCheckHook,
  python-dotenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "environs";
  version = "15.0.1";

  src = fetchFromGitHub {
    owner = "sloria";
    repo = "environs";
    tag = finalAttrs.version;
    hash = "sha256-rsXR3KjLRdGnF8EX0TXzd0r61xY2rrNO5TDdoX1SnO0=";
  };

  nativeCheckInputs = [
    dj-database-url
    dj-email-url
    django-cache-url
    pytestCheckHook
  ];

  build-system = [ flit-core ];

  dependencies = [
    marshmallow
    python-dotenv
  ];

  pyproject = true;
  pythonImportsCheck = [ "environs" ];

  meta = {
    description = "Python module for environment variable parsing";
    homepage = "https://github.com/sloria/environs";
    changelog = "https://github.com/sloria/environs/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
