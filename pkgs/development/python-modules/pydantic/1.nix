{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # tests
  distutils,
  email-validator,
  pytest-mock,
  pytest7CheckHook,
  # optional-dependencies
  python-dotenv,
  pythonAtLeast,
  setuptools,
  # dependencies
  typing-extensions,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "pydantic";
  version = "1.10.24";

  src = fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "v${version}";
    hash = "sha256-eDmVpo6tI6a1lfBOU7Bvq9Wv/+I959c7krYPzZEoQig=";
  };

  nativeCheckInputs = [
    distutils
    pytest-mock
    pytest7CheckHook
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    cython
    setuptools
  ];

  dependencies = [ typing-extensions ];
  # https://github.com/pydantic/pydantic/pull/12263
  disabled = pythonAtLeast "3.14";
  enableParallelBuilding = true;

  optional-dependencies = {
    dotenv = [ python-dotenv ];
    email = [ email-validator ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pydantic" ];

  meta = {
    description = "Data validation and settings management using Python type hinting";
    homepage = "https://github.com/pydantic/pydantic";
    changelog = "https://github.com/pydantic/pydantic/blob/v${version}/HISTORY.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wd15 ];
  };
}
