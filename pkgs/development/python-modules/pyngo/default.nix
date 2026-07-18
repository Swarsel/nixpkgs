{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  django,
  # tests
  django-stubs,
  # build-system
  hatchling,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pyngo";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "yezz123";
    repo = "pyngo";
    tag = version;
    hash = "sha256-GThDsl1fnJ5oMvmJcJohs+H2GQxpacG1fp9C7JNmycs=";
  };

  nativeBuildInputs = [
    hatchling
  ];

  propagatedBuildInputs = [
    django
    pydantic
    typing-extensions
  ];

  nativeCheckInputs = [
    django-stubs
    pytestCheckHook
    pytest-asyncio
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyngo" ];

  pythonRelaxDeps = [
    "pydantic"
    "typing-extensions"
  ];

  meta = {
    description = "Pydantic model support for Django & Django-Rest-Framework";
    homepage = "https://github.com/yezz123/pyngo";
    changelog = "https://github.com/yezz123/pyngo/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
}
