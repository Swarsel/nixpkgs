{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  mypy-extensions,
  numpy,
  pydantic,
  pytest-asyncio,
  pytestCheckHook,
  toolz,
  typing-extensions,
  wrapt,
}:

buildPythonPackage rec {
  pname = "psygnal";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "pyapp-kit";
    repo = "psygnal";
    tag = "v${version}";
    hash = "sha256-7d9ejzdafoH14fKvYJd3OwYS0RGwDmMeLlj74qvsvjE=";
  };

  nativeCheckInputs = [
    numpy
    pydantic
    pytest-asyncio
    pytestCheckHook
    toolz
    wrapt
    attrs
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    mypy-extensions
    typing-extensions
  ];

  pyproject = true;

  pytestFlags = [
    "-Wignore::pydantic.warnings.PydanticDeprecatedSince211"
  ];

  pythonImportsCheck = [ "psygnal" ];

  meta = {
    description = "Implementation of Qt Signals";
    homepage = "https://github.com/pyapp-kit/psygnal";
    changelog = "https://github.com/pyapp-kit/psygnal/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ SomeoneSerge ];
  };
}
