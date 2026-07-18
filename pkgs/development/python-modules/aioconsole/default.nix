{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

# This package provides a binary "apython" which sometimes invokes
# [sys.executable, '-m', 'aioconsole'] as a subprocess. If apython is
# run directly out of this derivation, it won't work, because
# sys.executable will point to a Python binary that is not wrapped to
# be able to find aioconsole.
# However, apython will work fine when using python##.withPackages,
# because with python##.withPackages the sys.executable is already
# wrapped to be able to find aioconsole and any other packages.
buildPythonPackage (finalAttrs: {
  pname = "aioconsole";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "vxgmichel";
    repo = "aioconsole";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j4nzt8mvn+AYObh1lvgxS8wWK662KN+OxjJ2b5ZNAcQ=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail " --strict-markers --count 2 -vv" ""
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-cov-stub
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # OSError: AF_UNIX path too long
    "tests/test_server.py::test_uds_server[default]"
  ];

  disabledTests = [
    "test_interact_syntax_error"
    # Output and the sandbox don't work well together
    "test_interact_multiple_indented_lines"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aioconsole" ];

  meta = {
    description = "Asynchronous console and interfaces for asyncio";
    homepage = "https://github.com/vxgmichel/aioconsole";
    changelog = "https://github.com/vxgmichel/aioconsole/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "apython";
  };
})
