{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  pytest,
  pythonOlder,
  setuptools-scm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "pytest-asyncio";
  version = "1.4.0"; # N.B.: when updating, tests bleak and aioesphomeapi tests

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pytest-asyncio";
    tag = "v${version}";
    hash = "sha256-MuTLCRHCuD9TwJkMiFIC5Xv5Xz6NL8j4JZpW8BA45SI=";
  };

  outputs = [
    "out"
    "testout"
  ];

  buildInputs = [ pytest ];
  doCheck = false;

  postInstall = ''
    mkdir $testout
    cp -R tests $testout/tests
  '';

  build-system = [ setuptools-scm ];

  dependencies = lib.optionals (pythonOlder "3.13") [
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_asyncio" ];
  pythonRelaxDeps = [ "pytest" ];
  passthru.tests.pytest = callPackage ./tests.nix { };

  meta = {
    description = "Library for testing asyncio code with pytest";
    homepage = "https://github.com/pytest-dev/pytest-asyncio";
    changelog = "https://github.com/pytest-dev/pytest-asyncio/blob/${src.tag}/docs/reference/changelog.rst";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
