{
  lib,
  fetchFromGitHub,
  aiofiles,
  buildPythonPackage,
  cython,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "aiocsv";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "MKuranowski";
    repo = "aiocsv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WENNtQKvpUuoYai6r8nTRamwCOloVA42YoAA3JGK9B8=";
  };

  preBuild = ''
    export CYTHONIZE=1
  '';

  nativeCheckInputs = [
    aiofiles
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [
    cython
    setuptools
  ];

  dependencies = [ typing-extensions ];

  disabledTestPaths = [
    # Import issue
    "tests/test_parser.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "aiocsv" ];

  meta = {
    description = "Library for for asynchronous CSV reading/writing";
    homepage = "https://github.com/MKuranowski/aiocsv";
    changelog = "https://github.com/MKuranowski/aiocsv/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
})
