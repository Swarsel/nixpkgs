{
  lib,
  stdenv,
  fetchFromGitHub,
  # tests
  addBinToPathHook,
  ase,
  # dependencies
  bibtexparser,
  buildPythonPackage,
  # nativeBuildInputs
  cython,
  glibcLocales,
  joblib,
  matplotlib,
  monty,
  moyopy,
  # optional-dependencies
  netcdf4,
  networkx,
  numba,
  numpy,
  orjson,
  palettable,
  pandas,
  plotly,
  pybtex,
  pytest-xdist,
  pytestCheckHook,
  pythonAtLeast,
  requests,
  ruamel-yaml,
  scipy,
  # build-system
  setuptools,
  spglib,
  sympy,
  tabulate,
  tqdm,
  uncertainties,
  vtk,
}:

buildPythonPackage rec {
  pname = "pymatgen";
  version = "2025.10.7";

  src = fetchFromGitHub {
    owner = "materialsproject";
    repo = "pymatgen";
    tag = "v${version}";
    hash = "sha256-pbnWSmU2rtqUbjZBmzJz3HE1t5zZTJv7HSfrcVUFxmU=";
  };

  nativeBuildInputs = [
    cython
    glibcLocales
  ];

  nativeCheckInputs = [
    addBinToPathHook
    moyopy
    pytestCheckHook
    pytest-xdist
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck =
    # ensure tests can find these
    ''
      export PMG_TEST_FILES_DIR="$(realpath ./tests/files)"
    ''
    # Prevents 'Fatal Python error: Aborted' on darwin during checkPhase
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      export MPLBACKEND="Agg"
    '';

  build-system = [ setuptools ];

  dependencies = [
    bibtexparser
    joblib
    matplotlib
    monty
    networkx
    numpy
    orjson
    palettable
    pandas
    plotly
    pybtex
    requests
    ruamel-yaml
    scipy
    spglib
    sympy
    tabulate
    tqdm
    uncertainties
  ];

  disabled = pythonAtLeast "3.13";

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # Crash when running the pmg command
    # Critical error: required built-in appearance SystemAppearance not found
    "tests/cli/test_pmg_plot.py"

    # attempt to insert nil object from objects[1]
    # https://github.com/materialsproject/pymatgen/issues/4452
    "tests/io/abinit/test_abitimer.py"
  ];

  disabledTests = [
    # Flaky
    "test_numerical_eos_values"
    "test_pca"
    "test_static_si_no_kgrid"
    "test_thermal_conductivity"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64) [
    # AttributeError: 'NoneType' object has no attribute 'items'
    "test_mean_field"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # attempt to insert nil object from objects[1]
    "test_timer_10_2_7"
    "test_timer"
  ];

  optional-dependencies = {
    abinit = [ netcdf4 ];
    ase = [ ase ];

    electronic_structure = [
      # fdint
    ];

    mlp = [
      # chgnet
      # matgl
    ];

    numba = [ numba ];
    vis = [ vtk ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pymatgen" ];

  meta = {
    description = "Robust materials analysis code that defines core object representations for structures and molecules";
    homepage = "https://pymatgen.org/";
    changelog = "https://github.com/materialsproject/pymatgen/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
