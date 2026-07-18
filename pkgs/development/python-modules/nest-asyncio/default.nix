{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "nest-asyncio";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "erdewit";
    repo = "nest_asyncio";
    tag = "v${version}";
    hash = "sha256-5I5WItOl1QpyI4OXZgZf8GiQ7Jlo+SJbDicIbernaU4=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTestPaths = lib.optionals (pythonAtLeast "3.14") [
    "tests/nest_test.py::NestTest::test_timeout"
  ];

  pyproject = true;
  pythonImportsCheck = [ "nest_asyncio" ];

  meta = {
    description = "Patch asyncio to allow nested event loops";
    homepage = "https://github.com/erdewit/nest_asyncio";
    changelog = "https://github.com/erdewit/nest_asyncio/releases/tag/v${version}";
    license = lib.licenses.bsdOriginal;
    maintainers = [ ];
  };
}
