{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  distutils,
  greenlet,
  ipython,
  jinja2,
  pkg-config,
  pkgconfig,
  pkgs,
  pytest-cov-stub,
  pytest-textual-snapshot,
  pytestCheckHook,
  pythonOlder,
  rich,
  setuptools,
  textual,
}:

buildPythonPackage (finalAttrs: {
  pname = "memray";
  version = "1.19.3";

  src = fetchFromGitHub {
    owner = "bloomberg";
    repo = "memray";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A9XbVpuW/MlMNdFq5bbpg90GFh5c1aEWQOvGAOXyUgc=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    cython
    pkgs.libunwind
    pkgs.lz4
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    pkgs.elfutils # for `-ldebuginfod`
  ];

  nativeCheckInputs = [
    ipython
    pytest-cov-stub
    pytest-textual-snapshot
    pytestCheckHook
  ]
  ++ lib.optionals (pythonOlder "3.14") [ greenlet ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    distutils
    setuptools
  ];

  dependencies = [
    pkgconfig
    textual
    jinja2
    rich
  ];

  disabledTestPaths = [
    # Very time-consuming and some tests fails (performance-related?)
    "tests/integration/test_main.py"
  ];

  disabledTests = [
    # Import issue
    "test_header_allocator"
    "test_hybrid_stack_of_allocations_inside_ceval"

    # The following snapshot tests started failing since updating textual to 3.5.0
    "TestTUILooks"
    "test_merge_threads"
    "test_tui_basic"
    "test_tui_gradient"
    "test_tui_pause"
    "test_unmerge_threads"
  ];

  pyproject = true;
  pythonImportsCheck = [ "memray" ];

  meta = {
    description = "Memory profiler for Python";
    homepage = "https://bloomberg.github.io/memray/";
    changelog = "https://github.com/bloomberg/memray/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "memray";
  };
})
