{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  loguru,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "python-utils";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "WoLpH";
    repo = "python-utils";
    tag = "v${version}";
    hash = "sha256-lzLzYI5jShfIwQqvfA8UtPjGawXE80ww7jb/gPzpeDo=";
  };

  postPatch = ''
    sed -i pytest.ini \
      -e '/--cov/d' \
      -e '/--mypy/d'
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ]
  ++ optional-dependencies.loguru;

  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];

  disabledTests = [
    # Flaky tests
    "test_timeout_generator"
  ];

  enabledTestPaths = [ "_python_utils_tests" ];

  optional-dependencies = {
    loguru = [ loguru ];
  };

  pyproject = true;
  pythonImportsCheck = [ "python_utils" ];

  meta = {
    description = "Module with some convenient utilities";
    homepage = "https://github.com/WoLpH/python-utils";
    changelog = "https://github.com/wolph/python-utils/releases/tag/v${version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
