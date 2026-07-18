{
  lib,
  fetchFromGitHub,
  asgiref,
  async-timeout,
  buildPythonPackage,
  daphne,
  django,
  pytest-asyncio,
  pytest-django,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "channels";
  version = "4.3.2";

  src = fetchFromGitHub {
    owner = "django";
    repo = "channels";
    tag = version;
    hash = "sha256-KBjxaK2j9Xbz35IHqZK68cSLkUk4B7t+J7omcQAtuFM=";
  };

  nativeCheckInputs = [
    async-timeout
    pytest-asyncio
    pytest-django
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ setuptools ];

  dependencies = [
    asgiref
    django
  ];

  # won't run in sandbox
  disabledTestPaths = [
    "tests/sample_project/tests/test_selenium.py"
  ];

  optional-dependencies = {
    daphne = [ daphne ];
  };

  pyproject = true;
  pythonImportsCheck = [ "channels" ];

  meta = {
    description = "Brings event-driven capabilities to Django with a channel system";
    homepage = "https://github.com/django/channels";
    changelog = "https://github.com/django/channels/blob/${src.tag}/CHANGELOG.txt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fab ];
  };
}
