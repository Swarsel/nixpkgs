{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  decorator,
  flaky,
  h5io,
  hatch-vcs,
  hatchling,
  jinja2,
  lazy-loader,
  matplotlib,
  numpy,
  optipng,
  packaging,
  pandas,
  pooch,
  procps,
  pymatreader,
  pytest-cov-stub,
  pytest-timeout,
  pytestCheckHook,
  pythonAtLeast,
  scipy,
  tqdm,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "mne";
  version = "1.12.1";

  src = fetchFromGitHub {
    owner = "mne-tools";
    repo = "mne-python";
    tag = "v${version}";
    hash = "sha256-8PzYTG8z35IG0nVegoPaJB/vpULujqHDd2VtLeXS0SQ=";
  };

  postPatch = ''
    substituteInPlace doc/conf.py \
      --replace-fail '"optipng"' '"${lib.getExe optipng}"'
    substituteInPlace mne/utils/config.py \
      --replace-fail '"free"'   '"${lib.getExe' procps "free"}"' \
      --replace-fail '"sysctl"' '"${lib.getExe' procps "sysctl"}"'
  '';

  nativeCheckInputs = [
    flaky
    pandas
    pytestCheckHook
    pytest-cov-stub
    pytest-timeout
    writableTmpDirAsHomeHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = ''
    export MNE_SKIP_TESTING_DATASET_TESTS=true
    export MNE_SKIP_NETWORK_TESTS=1
  '';

  __structuredAttrs = true;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    numpy
    scipy
    matplotlib
    tqdm
    pooch
    decorator
    packaging
    jinja2
    lazy-loader
  ];

  disabledTestMarks = [
    "slowtest"
    "ultraslowtest"
    "pgtest"
  ];

  disabledTests = [
    # requires qtbot which is unmaintained/not in Nixpkgs:
    "test_plotting_scalebars"
    # tries to write a datetime object to hdf5, which fails:
    "test_hitachi_basic"
    # flaky
    "test_fine_cal_systems"
    "test_simulate_raw_bem"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # Fails when no "model name" is present in /proc/cpuinfo,
    # which is common on Arm Linux systems
    "test_sys_info_basic"
  ];

  optional-dependencies.hdf5 = [
    h5io
    pymatreader
  ];

  pyproject = true;
  pythonImportsCheck = [ "mne" ];

  meta = {
    description = "Magnetoencephelography and electroencephalography in Python";
    homepage = "https://mne.tools";
    changelog = "https://mne.tools/stable/changes/v${lib.versions.majorMinor version}.html";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      bcdarwin
    ];

    mainProgram = "mne";
  };
}
