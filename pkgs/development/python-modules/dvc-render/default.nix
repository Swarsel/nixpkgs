{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  flatten-dict,
  funcy,
  matplotlib,
  pytest-mock,
  pytest-test-utils,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  tabulate,
}:

buildPythonPackage (finalAttrs: {
  pname = "dvc-render";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "iterative";
    repo = "dvc-render";
    tag = finalAttrs.version;
    hash = "sha256-V4QVZu4PSOW9poT6YUWbgTjJpIJ8YUtGDAE4Ijgm5Ac=";
  };

  nativeCheckInputs = [
    funcy
    pytestCheckHook
    pytest-mock
    pytest-test-utils
  ]
  ++ finalAttrs.passthru.optional-dependencies.table
  ++ finalAttrs.passthru.optional-dependencies.markdown;

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [ "tests/test_vega.py" ];
  pyproject = true;
  pythonImportsCheck = [ "dvc_render" ];

  passthru.optional-dependencies = {
    markdown = [
      tabulate
      matplotlib
    ];

    table = [
      flatten-dict
      tabulate
    ];
  };

  meta = {
    description = "Library for rendering DVC plots";
    homepage = "https://github.com/iterative/dvc-render";
    changelog = "https://github.com/iterative/dvc-render/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
