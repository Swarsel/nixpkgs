{
  lib,
  stdenv,
  fetchFromGitHub,
  ast-serialize,
  # tests
  attrs,
  buildPythonPackage,
  filelock,
  gitUpdater,
  isPyPy,
  # nativeBuildInputs + propagates
  librt,
  # optionals
  lxml,
  # propagates
  mypy-extensions,
  nixosTests,
  # build-system
  pathspec,
  psutil,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  tomli,
  types-psutil,
  types-setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "mypy";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "python";
    repo = "mypy";
    tag = "v${version}";
    hash = "sha256-sm/pxQGxH5XuPH7B8i3fpp30KaFU9aSp6BT67UcDPvU=";
  };

  nativeBuildInputs = [
    librt
  ];

  # when testing reduce optimisation level to reduce build time by 20%
  env.MYPYC_OPT_LEVEL = 1;
  # Compile mypy with mypyc, which makes mypy about 4 times faster. The compiled
  # version is also the default in the wheels on Pypi that include binaries.
  # is64bit: unfortunately the build would exhaust all possible memory on i686-linux.
  env.MYPY_USE_MYPYC = stdenv.buildPlatform.is64bit;

  nativeCheckInputs = [
    attrs
    filelock
    pytest-xdist
    pytestCheckHook
    setuptools
    tomli
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    mypy-extensions
    pathspec
    setuptools
    types-psutil
    types-setuptools
    typing-extensions
    ast-serialize
  ];

  dependencies = [
    librt
    mypy-extensions
    pathspec
    typing-extensions
  ];

  # relies on several CPython internals
  disabled = isPyPy;

  disabledTestPaths = [
    # circular dependency on distutils
    "mypyc/test/test_external.py"
    # fails to find tyoing_extensions
    "mypy/test/testcmdline.py"
    "mypy/test/testdaemon.py"
    # fails to find setuptools
    "mypyc/test/test_commandline.py"
    # fails to find hatchling
    "mypy/test/testpep561.py"
  ]
  ++ lib.optionals stdenv.hostPlatform.isi686 [
    # https://github.com/python/mypy/issues/15221
    "mypyc/test/test_run.py"
  ];

  disabledTests = [
    # A change to the base64 decoder in CPython 3.13.13 and 3.14.4 causes this
    # test to fail. At the time of writing, upstream skips the test.
    # Upstream issue: https://github.com/python/mypy/issues/21120
    # CPython issue: https://github.com/python/cpython/issues/145264
    "testAllBase64Features_librt_experimental"
    # https://github.com/python/mypy/issues/21120
    "testAllBase64Features_librt"
    # fails to import librt
    "test_diff_cache_produces_valid_json"
  ]
  ++ lib.optionals (pythonAtLeast "3.12") [
    # requires distutils
    "test_c_unit_test"
  ];

  optional-dependencies = {
    dmypy = [ psutil ];
    reports = [ lxml ];
  };

  pyproject = true;

  pythonImportsCheck = [
    "mypy"
    "mypy.api"
    "mypy.fastparse"
    "mypy.types"
    "mypyc"
    "mypyc.analysis"
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isi686) [
    # ImportError: cannot import name 'map_instance_to_supertype' from partially initialized module 'mypy.maptype' (most likely due to a circular import)
    "mypy.report"
  ];

  passthru.tests = {
    # Failing typing checks on the test-driver result in channel blockers.
    inherit (nixosTests) nixos-test-driver;
  };

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Optional static typing for Python";
    homepage = "https://www.mypy-lang.org";
    changelog = "https://github.com/python/mypy/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mypy";
    downloadPage = "https://github.com/python/mypy";
  };
}
