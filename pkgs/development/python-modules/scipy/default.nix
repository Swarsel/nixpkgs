{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  # buildInputs
  # Upstream has support for using Darwin's Accelerate package. However this
  # requires a Darwin user to work on a nice way to do that via an override.
  # See:
  # https://github.com/scipy/scipy/blob/v1.14.0/scipy/meson.build#L194-L211
  blas,
  boost191,
  buildPythonPackage,
  # build-system
  cython,
  fetchpatch,
  gfortran,
  # tests
  hypothesis,
  lapack,
  meson-python,
  nukeReferences,
  # dependencies
  numpy,
  pkg-config,
  pooch,
  pybind11,
  pytest-xdist,
  pytestCheckHook,
  python,
  pythran,
  qhull,
  # Reverse dependency
  sage,
  setuptools,
  writeTextFile,
  xsimd,
}:

buildPythonPackage (finalAttrs: {
  pname = "scipy";
  version = "1.18.0";

  src = fetchFromGitHub {
    owner = "scipy";
    repo = "scipy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qVTFWYZ9krhZNYLyuZTfiS7UYmMZL40GFqod84l+VHI=";
    fetchSubmodules = true;
  };

  patches = [
    # Helps with cross compilation, see https://github.com/scipy/scipy/pull/18167
    (fetchpatch {
      excludes = [ "doc/source/building/cross_compilation.rst" ];
      hash = "sha256-R5rgSz/9+T2+fpDFTfZQLTvdISTGUAuHEBAWT39x9LQ=";
      url = "https://github.com/scipy/scipy/commit/33696c545b74d6fda6f6f39e818d26c2b7631498.patch";
    })
  ];

  postPatch = lib.optionalString (stdenv.hostPlatform.isDarwin) ''
    substituteInPlace scipy/meson.build \
      --replace-fail "r = run_command('xcrun', '-sdk', 'macosx', '--show-sdk-version', check: true)" ""
    substituteInPlace scipy/meson.build \
      --replace-fail "sdkVersion = r.stdout().strip()" "sdkVersion = '${stdenv.hostPlatform.darwinSdkVersion}'"
  '';

  buildInputs = [
    blas
    lapack
    pybind11
    pooch
    xsimd
    boost191
    qhull
  ];

  mesonFlags = [
    "-Dblas=${blas.pname}"
    "-Dlapack=${lapack.pname}"
    # We always run what's necessary for cross compilation, which is passing to
    # meson the proper cross compilation related arguments. See also:
    # https://docs.scipy.org/doc/scipy/building/cross_compilation.html
    "--cross-file=${finalAttrs.finalPackage.passthru.crossFile}"
    "-Duse-system-libraries=all"
  ];

  env.SCIPY_USE_G77_ABI_WRAPPER = 1;

  preConfigure = ''
    # Helps parallelization a bit
    export NPY_NUM_BUILD_JOBS=$NIX_BUILD_CORES
    # We download manually the datasets and this variable tells the pooch
    # library where these files are cached. See also:
    # https://github.com/scipy/scipy/pull/18518#issuecomment-1562350648 And at:
    # https://github.com/scipy/scipy/pull/17965#issuecomment-1560759962
    export XDG_CACHE_HOME=$PWD; export HOME=$(mktemp -d); mkdir scipy-data
  ''
  + (lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      d: dpath:
      # Actually copy the datasets
      "cp ${dpath} scipy-data/${d}.dat"
    ) finalAttrs.finalPackage.passthru.datasets
  ));

  doCheck = !(stdenv.hostPlatform.isx86_64 && stdenv.hostPlatform.isDarwin);

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
    pytest-xdist
  ];

  preCheck = ''
    cd $out
  '';

  # remove references to dev dependencies
  postInstall = ''
    nuke-refs $out/${python.sitePackages}/scipy/__config__.py
    rm $out/${python.sitePackages}/scipy/__pycache__/__config__.*.opt-1.pyc
  '';

  __darwinAllowLocalNetworking = true;

  build-system = [
    cython
    gfortran
    meson-python
    nukeReferences
    pythran
    pkg-config
    setuptools
  ];

  dependencies = [ numpy ];

  disabledTests = [
    # precision issues on at least some x86_64 and aarch64
    # see: https://github.com/scipy/scipy/issues/25488
    "test_nyquist"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # more flakiness
    # see: https://github.com/scipy/scipy/issues/25522
    "test_convergence"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # The following tests are broken on aarch64-darwin with newer compilers and library versions.
    # See https://github.com/scipy/scipy/issues/18308
    "test_a_b_neg_int_after_euler_hypergeometric_transformation"
    "test_dst4_definition_ortho"
    "test_load_mat4_le"
    "hyp2f1_test_case47"
    "hyp2f1_test_case3"
    "test_uint64_max"
    "test_large_m4" # https://github.com/scipy/scipy/issues/22466
    "test_spiral_cleanup"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isPower64 && stdenv.hostPlatform.isBigEndian) [
    # https://github.com/scipy/scipy/issues/24090
    "test_cython_api"
    "test_distance_transform_cdt05"
    "test_eval_chebyt_gh20129"
    "test_hyp0f1"
    "test_hyp0f1_gh5764"
    "test_simple_det_shapes_real_complex"
  ]
  ++ lib.optionals (python.isPy311) [
    # https://github.com/scipy/scipy/issues/22789 Observed only with Python 3.11
    "test_funcs"
  ];

  # disable stackprotector on aarch64-darwin for now
  #
  # build error:
  #
  # /private/tmp/nix-build-python3.9-scipy-1.6.3.drv-0/ccDEsw5U.s:109:15: error: index must be an integer in range [-256, 255].
  #
  #         ldr     x0, [x0, ___stack_chk_guard];momd
  #
  hardeningDisable = lib.optionals (stdenv.hostPlatform.isAarch64 && stdenv.hostPlatform.isDarwin) [
    "stackprotector"
  ];

  pyproject = true;
  requiredSystemFeatures = [ "big-parallel" ]; # the tests need lots of CPU time

  passthru = {
    inherit blas;

    # Additional cross compilation related properties that scipy reads in scipy/meson.build
    buildConfig = {
      properties = {
        host-python-path = python.interpreter;
        host-python-version = python.pythonVersion;
        numpy-include-dir = numpy.coreIncludeDir;
        pythran-include-dir = "${pythran}/${python.sitePackages}/pythran";
      };
    };

    crossFile = writeTextFile {
      name = "cross-file-scipy.conf";

      text = lib.generators.toINI {
        mkKeyValue = lib.generators.mkKeyValueDefault {
          mkValueString = v: "'${v}'";
        } " = ";
      } finalAttrs.finalPackage.passthru.buildConfig;
    };

    datasets = lib.mapAttrs (
      d: hash:
      fetchurl {
        inherit hash;
        url = "https://raw.githubusercontent.com/scipy/dataset-${d}/main/${d}.dat";
      }
    ) finalAttrs.finalPackage.passthru.datasetsHashes;

    # NOTE: Every once in a while, these hashes might need an update. Use:
    #
    #   nix build -Lf. --rebuild python3.pkgs.scipy.passthru.datasets
    #
    # To verify the hashes are correct.
    datasetsHashes = {
      ascent = "sha256-A84STBr8iA+HtV9rBhEQ4uHpOWeRhPVhTjjazGwZV+I=";
      ecg = "sha256-8grTNl+5t/hF0OXEi2/mcIE3fuRmw6Igt/afNciVi68=";
      face = "sha256-nYsLTQgTE+K0hXSMdwRy5ale0XOBRog9hMcDBJPoKIY=";
    };

    tests = {
      inherit sage;
    };
  };

  meta = {
    description = "SciPy (pronounced 'Sigh Pie') is open-source software for mathematics, science, and engineering";
    homepage = "https://www.scipy.org/";
    changelog = "https://github.com/scipy/scipy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
    downloadPage = "https://github.com/scipy/scipy";
  };
})
