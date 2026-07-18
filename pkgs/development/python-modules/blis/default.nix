{
  lib,
  stdenv,
  fetchFromGitHub,
  # passthru
  blis,
  buildPythonPackage,
  cython,
  fetchpatch2,
  gitUpdater,
  # tests
  hypothesis,
  numpy,
  numpy_1,
  pytestCheckHook,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "blis";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "explosion";
    repo = "cython-blis";
    tag = "release-v${version}";
    hash = "sha256-CCy5vYjj4pCOfpKSEjdHsA6XTW7Wl3UVN8FHUsAhmVk=";
  };

  patches = [
    # TODO: remove after next update
    (fetchpatch2 {
      hash = "sha256-zl+xIoYVjf13La53ocrL0ztx48sdJfWN1Y6px6Hgf9Q=";
      url = "https://github.com/explosion/cython-blis/commit/1498af063ea924e2e2334a3f5ab49ae1a66a8648.patch?full_index=1";
    })
  ];

  env =
    # Fallback to generic architectures when necessary:
    # https://github.com/explosion/cython-blis?tab=readme-ov-file#building-blis-for-alternative-architectures
    lib.optionalAttrs
      (
        # error: [Errno 2] No such file or directory: '/build/source/blis/_src/make/linux-cortexa57.jsonl'
        (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64)

        # cc1: error: bad value ‘knl’ for ‘-march=’ switch
        # https://gcc.gnu.org/gcc-15/changes.html#x86
        || (
          stdenv.hostPlatform.isLinux
          && stdenv.hostPlatform.isx86_64
          && stdenv.cc.isGNU
          && lib.versionAtLeast stdenv.cc.version "15"
        )
      )
      {
        BLIS_ARCH = "generic";
      };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  # remove src module, so tests use the installed module instead
  preCheck = ''
    rm -rf ./blis
  '';

  build-system = [
    setuptools
    cython
    numpy
  ];

  dependencies = [ numpy ];

  disabledTestPaths = [
    # ImportError: cannot import name 'NO_CONJUGATE' from 'blis.cy'
    "tests/test_dotv.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "blis" ];

  passthru = {
    tests = {
      numpy_1 = blis.overridePythonAttrs (old: {
        numpy = numpy_1;
      });
    };

    updateScript = gitUpdater {
      rev-prefix = "release-v";
    };
  };

  meta = {
    description = "BLAS-like linear algebra library";
    homepage = "https://github.com/explosion/cython-blis";
    changelog = "https://github.com/explosion/cython-blis/releases/tag/release-v${version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nickcao ];
  };
}
