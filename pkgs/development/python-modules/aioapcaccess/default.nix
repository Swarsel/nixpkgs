{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "aioapcaccess";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "yuxincs";
    repo = "aioapcaccess";
    tag = "v${version}";
    hash = "sha256-gCi0vo4w3jr4w5neQS9v821rdfE+SqnUkrOrEQUET7E=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioapcaccess" ];

  meta = {
    description = "Module for working with apcaccess";
    homepage = "https://github.com/yuxincs/aioapcaccess";
    changelog = "https://github.com/yuxincs/aioapcaccess/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
