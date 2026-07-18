{
  lib,
  fetchFromGitHub,
  cmake-lint,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cmake-lint";
  version = "1.4.3";

  src = fetchFromGitHub {
    owner = "cmake-lint";
    repo = "cmake-lint";
    tag = finalAttrs.version;
    hash = "sha256-/OuWwerBlJynEibaYo+jkLpHt4x9GZrqMRJNxgrDBlM=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    python3Packages.pytest-cov-stub
  ];

  build-system = [ python3Packages.setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "cmakelint" ];

  passthru.tests = {
    version = testers.testVersion { package = cmake-lint; };
  };

  meta = {
    description = "Static code checker for CMake files";
    homepage = "https://github.com/cmake-lint/cmake-lint";
    changelog = "https://github.com/cmake-lint/cmake-lint/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.luftmensch-luftmensch ];
    mainProgram = "cmakelint";
  };
})
