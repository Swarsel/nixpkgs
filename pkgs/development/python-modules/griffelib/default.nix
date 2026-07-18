{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  griffe,
  # build-system
  hatchling,
  jsonschema,
  mkdocstrings,
  pdm-backend,
  # optional-dependencies
  pip,
  platformdirs,
  pytestCheckHook,
  uv-dynamic-versioning,
  wheel,
}:

buildPythonPackage (finalAttrs: {
  pname = "griffelib";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "mkdocstrings";
    repo = "griffe";
    tag = finalAttrs.version;
    hash = "sha256-hNKL86LSE9PwIofxt2t5PrlThiX7hTgYADK2HDVhNjk=";
  };

  nativeCheckInputs = [
    griffe
    jsonschema
    mkdocstrings
    pytestCheckHook
  ];

  build-system = [
    hatchling
    pdm-backend
    uv-dynamic-versioning
  ];

  disabledTestPaths = [
    # missing griffecli
    "tests/test_api.py"
    "tests/test_git.py"
  ];

  optional-dependencies.pypi = [
    pip
    platformdirs
    wheel
  ];

  pyproject = true;

  pythonImportsCheck = [
    "griffe"
  ];

  sourceRoot = "${finalAttrs.src.name}/packages/griffelib";

  meta = {
    description = "Signatures for entire Python programs. Extract the structure, the frame, the skeleton of your project, to generate API documentation or find breaking changes in your API";
    homepage = "https://github.com/mkdocstrings/griffe";
    changelog = "https://github.com/mkdocstrings/griffe/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
